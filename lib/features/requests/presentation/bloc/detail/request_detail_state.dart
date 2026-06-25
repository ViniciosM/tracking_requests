import 'package:equatable/equatable.dart';
import 'package:tracking_requests/features/requests/domain/entities/request_entity.dart';

enum DetailStatus { initial, loading, loaded, updating, failure }

class RequestDetailState extends Equatable {
  final DetailStatus status;
  final RequestEntity? request;
  final String? errorMessage;

  const RequestDetailState({
    this.status = DetailStatus.initial,
    this.request,
    this.errorMessage,
  });

  RequestDetailState copyWith({
    DetailStatus? status,
    RequestEntity? request,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RequestDetailState(
      status: status ?? this.status,
      request: request ?? this.request,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, request, errorMessage];
}
