import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracking_requests/core/error/failures.dart';
import 'package:tracking_requests/features/requests/domain/entities/description_suggestion_entity.dart';
import 'package:tracking_requests/features/requests/domain/repositories/request_repository.dart';
import 'package:tracking_requests/features/requests/domain/usecases/suggest_description_usecase.dart';

class MockRequestRepository extends Mock implements RequestRepository {}

void main() {
  late SuggestDescriptionUseCase usecase;
  late MockRequestRepository repository;

  setUp(() {
    repository = MockRequestRepository();
    usecase = SuggestDescriptionUseCase(repository);
  });

  test('returns the suggested description for a valid title', () async {
    const tSuggestion = DescriptionSuggestionEntity(
      description:
          'Gostaria de reagendar minha consulta para a próxima semana.',
    );
    when(
      () => repository.suggestDescription(any()),
    ).thenAnswer((_) async => const Right(tSuggestion));

    final result = await usecase(
      const SuggestDescriptionParams('Reagendar consulta'),
    );

    expect(result, const Right(tSuggestion));
    verify(() => repository.suggestDescription('Reagendar consulta')).called(1);
  });

  test('rejects a too-short title without calling the LLM', () async {
    final result = await usecase(const SuggestDescriptionParams('oi'));

    expect(result.isLeft(), isTrue);
    result.fold(
      (f) => expect(f, isA<ValidationFailure>()),
      (_) => fail('left'),
    );
    verifyNever(() => repository.suggestDescription(any()));
  });
}
