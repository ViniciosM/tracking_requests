import 'package:dartz/dartz.dart';
import 'package:tracking_requests/core/error/failures.dart';
import 'package:tracking_requests/core/usecases/usecase.dart';
import 'package:tracking_requests/features/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase implements UseCase<Unit, NoParams> {
  final AuthRepository repository;
  const LogoutUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(NoParams params) => repository.logout();
}
