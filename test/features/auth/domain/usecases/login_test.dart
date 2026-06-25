import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracking_requests/core/error/failures.dart';
import 'package:tracking_requests/features/auth/domain/entities/session_entity.dart';
import 'package:tracking_requests/features/auth/domain/repositories/auth_repository.dart';
import 'package:tracking_requests/features/auth/domain/usecases/login_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase usecase;
  late MockAuthRepository repository;

  setUp(() {
    repository = MockAuthRepository();
    usecase = LoginUseCase(repository);
  });

  // Assert
  const tEmail = 'user@email.com';
  const tPassword = 'secret123';
  const tSession = SessionEntity(
    token: 'jwt',
    userId: '1',
    userName: 'User',
    email: tEmail,
  );

  test('delegates to repository and returns the session on success', () async {
    // Act
    when(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => const Right(tSession));

    final result = await usecase(
      const LoginParams(email: tEmail, password: tPassword),
    );

    // Assert
    expect(result, const Right(tSession));
    verify(
      () => repository.login(email: tEmail, password: tPassword),
    ).called(1);
  });

  test('returns ValidationFailure and never calls the repository '
      'when fields are empty', () async {
    // Act
    final result = await usecase(const LoginParams(email: '', password: ''));

    // Assert
    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure, isA<ValidationFailure>()),
      (_) => fail('Expected a ValidationFailure'),
    );
    verifyNever(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    );
  });

  test('forwards AuthFailure from the repository', () async {
    // Act
    when(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => const Left(AuthFailure('invalid')));

    final result = await usecase(
      const LoginParams(email: tEmail, password: tPassword),
    );

    // Assert
    expect(result, const Left(AuthFailure('invalid')));
  });
}
