import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracking_requests/core/usecases/usecase.dart';
import 'package:tracking_requests/features/auth/domain/repositories/auth_repository.dart';
import 'package:tracking_requests/features/auth/domain/usecases/logout_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LogoutUseCase usecase;
  late MockAuthRepository repository;

  setUp(() {
    repository = MockAuthRepository();
    usecase = LogoutUseCase(repository);
  });

  test('delegates logout to the repository', () async {
    // Act
    when(() => repository.logout()).thenAnswer((_) async => const Right(unit));

    final result = await usecase(const NoParams());

    // Assert
    expect(result, const Right(unit));
    verify(() => repository.logout()).called(1);
  });
}
