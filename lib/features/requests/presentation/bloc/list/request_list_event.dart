import 'package:equatable/equatable.dart';
import 'package:tracking_requests/core/enums/request_status_enum.dart';
import 'package:tracking_requests/features/requests/domain/entities/request_entity.dart';

sealed class RequestsListEvent extends Equatable {
  const RequestsListEvent();
  @override
  List<Object?> get props => [];
}

class ListStarted extends RequestsListEvent {
  const ListStarted();
}

class ListFilterChanged extends RequestsListEvent {
  final RequestStatusEnum? status; // null = "all"
  const ListFilterChanged(this.status);
  @override
  List<Object?> get props => [status];
}

class ListRefreshed extends RequestsListEvent {
  const ListRefreshed();
}

class ListLoadMoreRequested extends RequestsListEvent {
  const ListLoadMoreRequested();
}

class ListItemsUpdated extends RequestsListEvent {
  final List<RequestEntity> items;
  const ListItemsUpdated(this.items);
  @override
  List<Object?> get props => [items];
}

class ListConnectivityChanged extends RequestsListEvent {
  final bool isOnline;
  const ListConnectivityChanged(this.isOnline);
  @override
  List<Object?> get props => [isOnline];
}
