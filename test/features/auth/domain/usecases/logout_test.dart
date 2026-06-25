import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracking_requests/core/usecases/usecase.dart';
import 'package:tracking_requests/features/auth/domain/entities/session_entity.dart';
import 'package:tracking_requests/features/auth/domain/repositories/auth_repository.dart';
import 'package:tracking_requests/features/auth/domain/usecases/check_auth_status_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late CheckAuthStatusUseCase usecase;
  late MockAuthRepository repository;

  setUp(() {
    repository = MockAuthRepository();
    usecase = CheckAuthStatusUseCase(repository);
  });

  test('returns the stored session when present', () async {
    // Arrange
    const tSession = SessionEntity(
      token: 'jwt',
      userId: '1',
      userName: 'User',
      email: 'user@email.com',
    );

    // Act
    when(
      () => repository.getStoredSession(),
    ).thenAnswer((_) async => const Right(tSession));

    final result = await usecase(const NoParams());

    // Assert
    expect(result, const Right(tSession));
  });

  test('returns null when there is no stored session', () async {
    // Act
    when(
      () => repository.getStoredSession(),
    ).thenAnswer((_) async => const Right(null));

    final result = await usecase(const NoParams());

    // Assert
    expect(result, const Right<dynamic, SessionEntity?>(null));
  });
}
