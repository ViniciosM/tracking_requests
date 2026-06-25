import 'package:dartz/dartz.dart';
import 'package:tracking_requests/features/auth/domain/entities/session_entity.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final AuthLocalDataSource local;

  AuthRepositoryImpl({required this.remote, required this.local});

  @override
  Future<Either<Failure, SessionEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final session = await remote.login(email: email, password: password);
      await local.cacheSession(session);
      return Right(session);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await local.clear();
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, SessionEntity?>> getStoredSession() async {
    try {
      final session = await local.getSession();
      return Right(session);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
