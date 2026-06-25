import 'package:equatable/equatable.dart';
import 'package:tracking_requests/core/enums/request_status_enum.dart';
import 'package:tracking_requests/features/requests/domain/entities/request_entity.dart';

enum ListStatus { initial, loading, loaded, failure }

const Object _sentinel = Object();

class RequestsListState extends Equatable {
  final ListStatus status;
  final List<RequestEntity> items;
  final RequestStatusEnum? filter;
  final int page;
  final bool hasReachedMax;
  final bool isRefreshing;
  final bool isLoadingMore;
  final bool isOnline;
  final String? errorMessage;

  const RequestsListState({
    this.status = ListStatus.initial,
    this.items = const [],
    this.filter,
    this.page = 1,
    this.hasReachedMax = false,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.isOnline = true,
    this.errorMessage,
  });

  RequestsListState copyWith({
    ListStatus? status,
    List<RequestEntity>? items,
    Object? filter = _sentinel,
    int? page,
    bool? hasReachedMax,
    bool? isRefreshing,
    bool? isLoadingMore,
    bool? isOnline,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RequestsListState(
      status: status ?? this.status,
      items: items ?? this.items,
      filter: filter == _sentinel ? this.filter : filter as RequestStatusEnum?,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isOnline: isOnline ?? this.isOnline,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    filter,
    page,
    hasReachedMax,
    isRefreshing,
    isLoadingMore,
    isOnline,
    errorMessage,
  ];
}
