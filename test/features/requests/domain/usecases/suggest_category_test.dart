import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracking_requests/core/enums/request_category_enum.dart';
import 'package:tracking_requests/core/error/failures.dart';
import 'package:tracking_requests/features/requests/domain/entities/category_suggestion_entity.dart';
import 'package:tracking_requests/features/requests/domain/repositories/request_repository.dart';
import 'package:tracking_requests/features/requests/domain/usecases/suggest_category_usecase.dart';

class MockRequestRepository extends Mock implements RequestRepository {}

void main() {
  late SuggestCategoryUseCase usecase;
  late MockRequestRepository repository;

  setUp(() {
    repository = MockRequestRepository();
    usecase = SuggestCategoryUseCase(repository);
  });

  test('returns the suggestion for a valid description', () async {
    // Arrange
    const tSuggestion = CategorySuggestionEntity(
      category: RequestCategoryEnum.appointment,
      summary: 'Reagendamento de consulta.',
    );

    // Act
    when(
      () => repository.suggestCategory(any()),
    ).thenAnswer((_) async => const Right(tSuggestion));

    final result = await usecase(
      const SuggestCategoryParams('Preciso reagendar minha consulta.'),
    );

    // Assert
    expect(result, const Right(tSuggestion));
    verify(
      () => repository.suggestCategory('Preciso reagendar minha consulta.'),
    ).called(1);
  });

  test('rejects a too-short description without calling the LLM', () async {
    // Act
    final result = await usecase(const SuggestCategoryParams('oi'));

    // Assert
    expect(result.isLeft(), isTrue);
    result.fold(
      (f) => expect(f, isA<ValidationFailure>()),
      (_) => fail('left'),
    );
    verifyNever(() => repository.suggestCategory(any()));
  });
}
