import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:tracking_requests/core/enums/request_status_enum.dart';
import 'package:tracking_requests/core/error/failures.dart';
import 'package:tracking_requests/core/usecases/usecase.dart';
import 'package:tracking_requests/features/requests/domain/repositories/request_repository.dart';

class RefreshRequestsUseCase implements UseCase<Unit, RefreshRequestsParams> {
  final RequestRepository repository;
  const RefreshRequestsUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(RefreshRequestsParams params) =>
      repository.refreshRequests(status: params.status, page: params.page);
}

class RefreshRequestsParams extends Equatable {
  final RequestStatusEnum? status;
  final int page;
  const RefreshRequestsParams({this.status, this.page = 1});

  @override
  List<Object?> get props => [status, page];
}
