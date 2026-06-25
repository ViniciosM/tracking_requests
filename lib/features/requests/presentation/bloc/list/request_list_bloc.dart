import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:tracking_requests/core/constants/app_constants.dart';
import 'package:tracking_requests/core/enums/request_status_enum.dart';
import 'package:tracking_requests/core/services/connectivity_service.dart';
import 'package:tracking_requests/core/services/sync_service.dart';
import 'package:tracking_requests/features/requests/domain/entities/request_entity.dart';
import 'package:tracking_requests/features/requests/domain/usecases/refresh_requests_usecase.dart';
import 'package:tracking_requests/features/requests/domain/usecases/watch_requests_usecase.dart';
import 'package:tracking_requests/features/requests/presentation/bloc/list/request_list_event.dart';
import 'package:tracking_requests/features/requests/presentation/bloc/list/request_list_state.dart';

class RequestsListBloc extends Bloc<RequestsListEvent, RequestsListState> {
  final WatchRequestsUseCase watchRequests;
  final RefreshRequestsUseCase refreshRequests;
  final SyncService syncService;
  final ConnectivityService connectivity;

  StreamSubscription<List<RequestEntity>>? _itemsSub;
  StreamSubscription<bool>? _connSub;

  RequestsListBloc({
    required this.watchRequests,
    required this.refreshRequests,
    required this.syncService,
    required this.connectivity,
  }) : super(const RequestsListState()) {
    on<ListStarted>(_onStarted);
    on<ListFilterChanged>(_onFilterChanged);
    on<ListRefreshed>(_onRefreshed);
    on<ListLoadMoreRequested>(_onLoadMore);
    on<ListItemsUpdated>(_onItemsUpdated);
    on<ListConnectivityChanged>(
      (event, emit) => emit(state.copyWith(isOnline: event.isOnline)),
    );
  }

  Future<void> _onStarted(
    ListStarted event,
    Emitter<RequestsListState> emit,
  ) async {
    emit(state.copyWith(status: ListStatus.loading));
    _listenConnectivity();
    _subscribe(filter: state.filter, page: 1);
    await _fetch(page: 1, filter: state.filter, emit: emit);
  }

  Future<void> _onFilterChanged(
    ListFilterChanged event,
    Emitter<RequestsListState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ListStatus.loading,
        filter: event.status,
        page: 1,
        hasReachedMax: false,
      ),
    );
    _subscribe(filter: event.status, page: 1);
    await _fetch(page: 1, filter: event.status, emit: emit);
  }

  Future<void> _onRefreshed(
    ListRefreshed event,
    Emitter<RequestsListState> emit,
  ) async {
    emit(state.copyWith(isRefreshing: true, page: 1, hasReachedMax: false));
    _subscribe(filter: state.filter, page: 1);
    await syncService.sync();
    await _fetch(page: 1, filter: state.filter, emit: emit);
    emit(state.copyWith(isRefreshing: false));
  }

  Future<void> _onLoadMore(
    ListLoadMoreRequested event,
    Emitter<RequestsListState> emit,
  ) async {
    if (state.hasReachedMax || state.isLoadingMore) return;
    final nextPage = state.page + 1;
    emit(state.copyWith(isLoadingMore: true, page: nextPage));
    _subscribe(filter: state.filter, page: nextPage);
    await _fetch(page: nextPage, filter: state.filter, emit: emit);
  }

  void _onItemsUpdated(
    ListItemsUpdated event,
    Emitter<RequestsListState> emit,
  ) {
    final reachedMax = event.items.length < state.page * AppConstants.pageSize;
    emit(
      state.copyWith(
        status: ListStatus.loaded,
        items: event.items,
        hasReachedMax: reachedMax,
        isRefreshing: false,
        isLoadingMore: false,
        clearError: true,
      ),
    );
  }

  void _subscribe({RequestStatusEnum? filter, required int page}) {
    _itemsSub?.cancel();
    _itemsSub = watchRequests(
      WatchRequestsParams(status: filter, limit: page * AppConstants.pageSize),
    ).listen((items) => add(ListItemsUpdated(items)));
  }

  void _listenConnectivity() {
    _connSub?.cancel();
    _connSub = connectivity.onStatusChange.listen(
      (online) => add(ListConnectivityChanged(online)),
    );
  }

  Future<void> _fetch({
    required int page,
    required RequestStatusEnum? filter,
    required Emitter<RequestsListState> emit,
  }) async {
    final result = await refreshRequests(
      RefreshRequestsParams(status: filter, page: page),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: state.items.isEmpty ? ListStatus.failure : ListStatus.loaded,
          isRefreshing: false,
          isLoadingMore: false,
          errorMessage: failure.message,
        ),
      ),
      (_) {},
    );
  }

  @override
  Future<void> close() async {
    await _itemsSub?.cancel();
    await _connSub?.cancel();
    return super.close();
  }
}
