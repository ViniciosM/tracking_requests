import 'package:dartz/dartz.dart';
import 'package:tracking_requests/core/error/failures.dart';
import 'package:tracking_requests/features/auth/domain/entities/session_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, SessionEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, Unit>> logout();

  Future<Either<Failure, SessionEntity?>> getStoredSession();
}
