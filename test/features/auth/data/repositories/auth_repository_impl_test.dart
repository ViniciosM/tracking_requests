import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracking_requests/core/error/exceptions.dart';
import 'package:tracking_requests/core/error/failures.dart';
import 'package:tracking_requests/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:tracking_requests/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:tracking_requests/features/auth/data/models/session_model.dart';
import 'package:tracking_requests/features/auth/data/repositories/auth_repository_impl.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource remote;
  late MockAuthLocalDataSource local;

  // Arrange
  const tModel = SessionModel(
    token: 'jwt-123',
    userId: '1',
    userName: 'Maria Souza',
    email: 'user@email.com',
  );

  setUpAll(() => registerFallbackValue(tModel));

  setUp(() {
    remote = MockAuthRemoteDataSource();
    local = MockAuthLocalDataSource();
    repository = AuthRepositoryImpl(remote: remote, local: local);
  });

  group('login', () {
    test('caches the session and returns it on success', () async {
      // Act
      when(
        () => remote.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => tModel);
      when(() => local.cacheSession(any())).thenAnswer((_) async {});

      final result = await repository.login(
        email: 'user@email.com',
        password: 'password123',
      );

      // Assert
      expect(result, const Right<Failure, dynamic>(tModel));
      verify(() => local.cacheSession(tModel)).called(1);
    });

    test('maps AuthException to AuthFailure and does not cache', () async {
      // Act
      when(
        () => remote.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const AuthException(message: 'invalid'));

      final result = await repository.login(
        email: 'x@y.com',
        password: 'wrong',
      );

      // Assert
      expect(result, const Left(AuthFailure('invalid')));
      verifyNever(() => local.cacheSession(any()));
    });

    test('maps NetworkException to NetworkFailure', () async {
      // Act
      when(
        () => remote.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const NetworkException());

      final result = await repository.login(email: 'x@y.com', password: 'p');

      // Assert
      expect(result, const Left(NetworkFailure()));
    });
  });

  group('getStoredSession', () {
    test('returns the cached session', () async {
      // Act
      when(() => local.getSession()).thenAnswer((_) async => tModel);

      final result = await repository.getStoredSession();

      // Assert
      expect(result, const Right<Failure, dynamic>(tModel));
    });

    test('returns null when not logged in', () async {
      when(() => local.getSession()).thenAnswer((_) async => null);

      // Act
      final result = await repository.getStoredSession();

      // Assert
      expect(result.getOrElse(() => tModel), isNull);
    });
  });

  group('logout', () {
    test('clears local storage and returns unit', () async {
      when(() => local.clear()).thenAnswer((_) async {});

      // Act
      final result = await repository.logout();

      // Assert
      expect(result, const Right<Failure, Unit>(unit));
      verify(() => local.clear()).called(1);
    });
  });
}
