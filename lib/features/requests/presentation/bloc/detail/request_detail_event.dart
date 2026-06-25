import 'package:equatable/equatable.dart';
import 'package:tracking_requests/core/enums/request_status_enum.dart';

sealed class RequestDetailEvent extends Equatable {
  const RequestDetailEvent();
  @override
  List<Object?> get props => [];
}

class DetailRequested extends RequestDetailEvent {
  final String localId;
  const DetailRequested(this.localId);
  @override
  List<Object?> get props => [localId];
}

class DetailStatusChanged extends RequestDetailEvent {
  final RequestStatusEnum status;
  const DetailStatusChanged(this.status);
  @override
  List<Object?> get props => [status];
}

class RequestStatus {}
