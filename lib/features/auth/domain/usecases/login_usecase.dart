import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:tracking_requests/core/error/failures.dart';
import 'package:tracking_requests/core/usecases/usecase.dart';
import 'package:tracking_requests/features/auth/domain/entities/session_entity.dart';
import 'package:tracking_requests/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase implements UseCase<SessionEntity, LoginParams> {
  final AuthRepository repository;
  const LoginUseCase(this.repository);

  @override
  Future<Either<Failure, SessionEntity>> call(LoginParams params) {
    if (params.email.trim().isEmpty || params.password.isEmpty) {
      return Future.value(
        const Left(ValidationFailure('E-mail e senha são obrigatórios.')),
      );
    }
    return repository.login(
      email: params.email.trim(),
      password: params.password,
    );
  }
}

class LoginParams extends Equatable {
  final String email;
  final String password;
  const LoginParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}
