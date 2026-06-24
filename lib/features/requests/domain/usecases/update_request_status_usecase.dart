import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:tracking_requests/core/enums/request_status_enum.dart';
import 'package:tracking_requests/core/error/failures.dart';
import 'package:tracking_requests/core/usecases/usecase.dart';
import 'package:tracking_requests/features/requests/domain/entities/request_entity.dart';
import 'package:tracking_requests/features/requests/domain/repositories/request_repository.dart';

class UpdateRequestStatusUseCase
    implements UseCase<RequestEntity, UpdateRequestStatusParams> {
  final RequestRepository repository;
  const UpdateRequestStatusUseCase(this.repository);

  @override
  Future<Either<Failure, RequestEntity>> call(
    UpdateRequestStatusParams params,
  ) => repository.updateStatus(localId: params.localId, status: params.status);
}

class UpdateRequestStatusParams extends Equatable {
  final String localId;
  final RequestStatusEnum status;
  const UpdateRequestStatusParams({
    required this.localId,
    required this.status,
  });

  @override
  List<Object?> get props => [localId, status];
}
