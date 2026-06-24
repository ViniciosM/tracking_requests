import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:tracking_requests/core/error/failures.dart';
import 'package:tracking_requests/core/usecases/usecase.dart';
import 'package:tracking_requests/features/requests/domain/entities/request_entity.dart';
import 'package:tracking_requests/features/requests/domain/repositories/request_repository.dart';

class GetRequestDetailUseCase
    implements UseCase<RequestEntity, GetRequestDetailParams> {
  final RequestRepository repository;
  const GetRequestDetailUseCase(this.repository);

  @override
  Future<Either<Failure, RequestEntity>> call(GetRequestDetailParams params) =>
      repository.getRequestById(params.localId);
}

class GetRequestDetailParams extends Equatable {
  final String localId;
  const GetRequestDetailParams(this.localId);

  @override
  List<Object?> get props => [localId];
}
