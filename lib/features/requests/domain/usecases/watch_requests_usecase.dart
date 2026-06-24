import 'package:equatable/equatable.dart';
import 'package:tracking_requests/core/constants/app_constants.dart';
import 'package:tracking_requests/core/enums/request_status_enum.dart';
import 'package:tracking_requests/core/usecases/usecase.dart';
import 'package:tracking_requests/features/requests/domain/entities/request_entity.dart';
import 'package:tracking_requests/features/requests/domain/repositories/request_repository.dart';

class WatchRequestsUseCase
    implements StreamUseCase<List<RequestEntity>, WatchRequestsParams> {
  final RequestRepository repository;
  const WatchRequestsUseCase(this.repository);

  @override
  Stream<List<RequestEntity>> call(WatchRequestsParams params) =>
      repository.watchRequests(status: params.status, limit: params.limit);
}

class WatchRequestsParams extends Equatable {
  final RequestStatusEnum? status;
  final int limit;
  const WatchRequestsParams({this.status, this.limit = AppConstants.pageSize});

  @override
  List<Object?> get props => [status, limit];
}
