import 'package:dartz/dartz.dart';
import 'package:tracking_requests/core/error/failures.dart';
import 'package:tracking_requests/core/usecases/usecase.dart';
import 'package:tracking_requests/features/auth/domain/entities/session_entity.dart';
import 'package:tracking_requests/features/auth/domain/repositories/auth_repository.dart';

class CheckAuthStatusUseCase implements UseCase<SessionEntity?, NoParams> {
  final AuthRepository repository;
  const CheckAuthStatusUseCase(this.repository);

  @override
  Future<Either<Failure, SessionEntity?>> call(NoParams params) =>
      repository.getStoredSession();
}
