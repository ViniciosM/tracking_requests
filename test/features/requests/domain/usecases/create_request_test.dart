import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracking_requests/core/enums/request_category_enum.dart';
import 'package:tracking_requests/core/enums/request_priority_enum.dart';
import 'package:tracking_requests/core/error/failures.dart';
import 'package:tracking_requests/features/requests/domain/repositories/request_repository.dart';
import 'package:tracking_requests/features/requests/domain/usecases/create_request_usecase.dart';

import '../../../../_fixtures.dart';

class MockRequestRepository extends Mock implements RequestRepository {}

void main() {
  late CreateRequestUseCase usecase;
  late MockRequestRepository repository;

  setUpAll(() {
    registerFallbackValue(RequestCategoryEnum.general);
    registerFallbackValue(RequestPriorityEnum.medium);
  });

  setUp(() {
    repository = MockRequestRepository();
    usecase = CreateRequestUseCase(repository);
  });

  // Arrange
  const validParams = CreateRequestParams(
    title: 'Reagendar consulta',
    description: 'Preciso reagendar minha consulta de cardiologia.',
    category: RequestCategoryEnum.appointment,
    priority: RequestPriorityEnum.high,
  );

  test('persists via repository and returns the created request', () async {
    // Arrange
    final tRequest = buildRequest();

    // Act
    when(
      () => repository.createRequest(
        title: any(named: 'title'),
        description: any(named: 'description'),
        category: any(named: 'category'),
        priority: any(named: 'priority'),
      ),
    ).thenAnswer((_) async => Right(tRequest));

    final result = await usecase(validParams);

    // Assert
    expect(result, Right(tRequest));
    verify(
      () => repository.createRequest(
        title: 'Reagendar consulta',
        description: 'Preciso reagendar minha consulta de cardiologia.',
        category: RequestCategoryEnum.appointment,
        priority: RequestPriorityEnum.high,
      ),
    ).called(1);
  });

  test('rejects an empty title without calling the repository', () async {
    // Arrange
    final params = const CreateRequestParams(
      title: '   ',
      description: 'Uma descrição suficientemente longa.',
      category: RequestCategoryEnum.general,
      priority: RequestPriorityEnum.low,
    );

    // Act
    final result = await usecase(params);

    // Assert
    expect(result.isLeft(), isTrue);
    result.fold(
      (f) => expect(f, isA<ValidationFailure>()),
      (_) => fail('left'),
    );
    verifyNever(
      () => repository.createRequest(
        title: any(named: 'title'),
        description: any(named: 'description'),
        category: any(named: 'category'),
        priority: any(named: 'priority'),
      ),
    );
  });

  test('rejects a description below the minimum length', () async {
    // Arrange
    final params = const CreateRequestParams(
      title: 'Título válido',
      description: 'curto',
      category: RequestCategoryEnum.general,
      priority: RequestPriorityEnum.low,
    );

    // Act
    final result = await usecase(params);

    // Assert
    expect(result.isLeft(), isTrue);
    result.fold(
      (f) => expect(f, isA<ValidationFailure>()),
      (_) => fail('left'),
    );
    verifyNever(
      () => repository.createRequest(
        title: any(named: 'title'),
        description: any(named: 'description'),
        category: any(named: 'category'),
        priority: any(named: 'priority'),
      ),
    );
  });
}
