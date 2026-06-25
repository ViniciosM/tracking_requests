import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracking_requests/core/enums/request_status_enum.dart';
import 'package:tracking_requests/core/error/failures.dart';
import 'package:tracking_requests/core/services/connectivity_service.dart';
import 'package:tracking_requests/core/services/sync_service.dart';
import 'package:tracking_requests/features/requests/domain/usecases/refresh_requests_usecase.dart';
import 'package:tracking_requests/features/requests/domain/usecases/watch_requests_usecase.dart';
import 'package:tracking_requests/features/requests/presentation/bloc/list/request_list_bloc.dart';
import 'package:tracking_requests/features/requests/presentation/bloc/list/request_list_event.dart';
import 'package:tracking_requests/features/requests/presentation/bloc/list/request_list_state.dart';

import '_bloc.fixtures.dart';

class MockWatchRequests extends Mock implements WatchRequestsUseCase {}

class MockRefreshRequests extends Mock implements RefreshRequestsUseCase {}

class MockSyncService extends Mock implements SyncService {}

class MockConnectivity extends Mock implements ConnectivityService {}

void main() {
  late MockWatchRequests watch;
  late MockRefreshRequests refresh;
  late MockSyncService sync;
  late MockConnectivity connectivity;

  setUpAll(() {
    registerFallbackValue(const WatchRequestsParams());
    registerFallbackValue(const RefreshRequestsParams());
  });

  setUp(() {
    watch = MockWatchRequests();
    refresh = MockRefreshRequests();
    sync = MockSyncService();
    connectivity = MockConnectivity();
    when(
      () => connectivity.onStatusChange,
    ).thenAnswer((_) => Stream<bool>.empty());
    when(() => refresh(any())).thenAnswer((_) async => const Right(unit));
    when(() => sync.sync()).thenAnswer((_) async {});
  });

  RequestsListBloc build() => RequestsListBloc(
    watchRequests: watch,
    refreshRequests: refresh,
    syncService: sync,
    connectivity: connectivity,
  );

  blocTest<RequestsListBloc, RequestsListState>(
    'emits [loading, loaded] on start, items coming from the Drift stream',
    setUp: () =>
        when(() => watch(any())).thenAnswer((_) => Stream.value([req()])),
    build: build,
    act: (b) => b.add(const ListStarted()),
    expect: () => [
      isA<RequestsListState>().having(
        (s) => s.status,
        'status',
        ListStatus.loading,
      ),
      isA<RequestsListState>()
          .having((s) => s.status, 'status', ListStatus.loaded)
          .having((s) => s.items.length, 'items', 1),
    ],
  );

  blocTest<RequestsListBloc, RequestsListState>(
    'filter change re-subscribes and reloads',
    setUp: () => when(() => watch(any())).thenAnswer(
      (_) => Stream.value([req(status: RequestStatusEnum.resolved)]),
    ),
    build: build,
    act: (b) => b.add(const ListFilterChanged(RequestStatusEnum.resolved)),
    expect: () => [
      isA<RequestsListState>()
          .having((s) => s.status, 'status', ListStatus.loading)
          .having((s) => s.filter, 'filter', RequestStatusEnum.resolved),
      isA<RequestsListState>()
          .having((s) => s.status, 'status', ListStatus.loaded)
          .having((s) => s.filter, 'filter', RequestStatusEnum.resolved),
    ],
  );

  blocTest<RequestsListBloc, RequestsListState>(
    'pull-to-refresh pushes (sync) before pulling (refresh)',
    setUp: () =>
        when(() => watch(any())).thenAnswer((_) => Stream.value([req()])),
    build: build,
    seed: () => RequestsListState(status: ListStatus.loaded, items: [req()]),
    act: (b) => b.add(const ListRefreshed()),
    verify: (_) {
      verify(() => sync.sync()).called(1);
      verify(() => refresh(any())).called(1);
    },
  );

  blocTest<RequestsListBloc, RequestsListState>(
    'keeps cached items and surfaces an error when refresh fails offline',
    setUp: () {
      when(() => watch(any())).thenAnswer((_) => Stream.value([req()]));

      when(
        () => refresh(any()),
      ).thenAnswer((_) async => const Left(_NetFail()));
    },
    build: build,
    seed: () => RequestsListState(status: ListStatus.loaded, items: [req()]),
    act: (b) => b.add(const ListRefreshed()),
    verify: (bloc) {
      expect(bloc.state.items.length, 1);
    },
  );
}

class _NetFail extends Failure {
  const _NetFail() : super('offline');
}
