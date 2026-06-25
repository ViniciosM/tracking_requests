import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracking_requests/core/enums/request_status_enum.dart';
import 'package:tracking_requests/core/error/failures.dart';
import 'package:tracking_requests/features/requests/domain/usecases/get_request_detail_usecase.dart';
import 'package:tracking_requests/features/requests/domain/usecases/update_request_status_usecase.dart';
import 'package:tracking_requests/features/requests/presentation/bloc/detail/request_detail_bloc.dart';
import 'package:tracking_requests/features/requests/presentation/bloc/detail/request_detail_event.dart';
import 'package:tracking_requests/features/requests/presentation/bloc/detail/request_detail_state.dart';

import '_bloc.fixtures.dart';

class MockGetRequestDetail extends Mock implements GetRequestDetailUseCase {}

class MockUpdateRequestStatus extends Mock
    implements UpdateRequestStatusUseCase {}

void main() {
  late MockGetRequestDetail getDetail;
  late MockUpdateRequestStatus updateStatus;

  setUpAll(() {
    registerFallbackValue(const GetRequestDetailParams('x'));
    registerFallbackValue(
      const UpdateRequestStatusParams(
        localId: 'x',
        status: RequestStatusEnum.open,
      ),
    );
  });

  setUp(() {
    getDetail = MockGetRequestDetail();
    updateStatus = MockUpdateRequestStatus();
  });

  RequestDetailBloc build() => RequestDetailBloc(
    getRequestDetail: getDetail,
    updateRequestStatus: updateStatus,
  );

  blocTest<RequestDetailBloc, RequestDetailState>(
    'emits [loading, loaded] when the request is found',
    setUp: () =>
        when(() => getDetail(any())).thenAnswer((_) async => Right(req())),
    build: build,
    act: (b) => b.add(const DetailRequested('l1')),
    expect: () => [
      isA<RequestDetailState>().having(
        (s) => s.status,
        'status',
        DetailStatus.loading,
      ),
      isA<RequestDetailState>()
          .having((s) => s.status, 'status', DetailStatus.loaded)
          .having((s) => s.request?.localId, 'localId', 'l1'),
    ],
  );

  blocTest<RequestDetailBloc, RequestDetailState>(
    'optimistic status change emits [updating, loaded(updated)]',
    setUp: () => when(
      () => updateStatus(any()),
    ).thenAnswer((_) async => Right(req(status: RequestStatusEnum.resolved))),
    build: build,
    seed: () => RequestDetailState(status: DetailStatus.loaded, request: req()),
    act: (b) => b.add(const DetailStatusChanged(RequestStatusEnum.resolved)),
    expect: () => [
      isA<RequestDetailState>().having(
        (s) => s.status,
        'status',
        DetailStatus.updating,
      ),
      isA<RequestDetailState>()
          .having((s) => s.status, 'status', DetailStatus.loaded)
          .having(
            (s) => s.request?.status,
            'status',
            RequestStatusEnum.resolved,
          ),
    ],
  );

  blocTest<RequestDetailBloc, RequestDetailState>(
    'emits failure when loading fails',
    setUp: () => when(
      () => getDetail(any()),
    ).thenAnswer((_) async => const Left(CacheFailure('não encontrada'))),
    build: build,
    act: (b) => b.add(const DetailRequested('x')),
    expect: () => [
      isA<RequestDetailState>().having(
        (s) => s.status,
        'status',
        DetailStatus.loading,
      ),
      isA<RequestDetailState>().having(
        (s) => s.status,
        'status',
        DetailStatus.failure,
      ),
    ],
  );
}
