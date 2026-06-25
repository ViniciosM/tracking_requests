import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracking_requests/core/enums/request_category_enum.dart';
import 'package:tracking_requests/core/enums/request_priority_enum.dart';
import 'package:tracking_requests/core/error/failures.dart';
import 'package:tracking_requests/features/requests/domain/entities/category_suggestion_entity.dart';
import 'package:tracking_requests/features/requests/domain/usecases/create_request_usecase.dart';
import 'package:tracking_requests/features/requests/domain/usecases/suggest_category_usecase.dart';
import 'package:tracking_requests/features/requests/presentation/bloc/create/create_request_bloc.dart';
import 'package:tracking_requests/features/requests/presentation/bloc/create/create_request_event.dart';
import 'package:tracking_requests/features/requests/presentation/bloc/create/create_request_state.dart';

import '_bloc.fixtures.dart';

class MockCreateRequest extends Mock implements CreateRequestUseCase {}

class MockSuggestCategory extends Mock implements SuggestCategoryUseCase {}

void main() {
  late MockCreateRequest createRequest;
  late MockSuggestCategory suggestCategory;

  setUpAll(() {
    registerFallbackValue(const SuggestCategoryParams('x'));
    registerFallbackValue(
      const CreateRequestParams(
        title: 'x',
        description: 'x',
        category: RequestCategoryEnum.general,
        priority: RequestPriorityEnum.low,
      ),
    );
  });

  setUp(() {
    createRequest = MockCreateRequest();
    suggestCategory = MockSuggestCategory();
  });

  CreateRequestBloc build() => CreateRequestBloc(
    createRequest: createRequest,
    suggestCategory: suggestCategory,
  );

  blocTest<CreateRequestBloc, CreateRequestState>(
    'AI suggestion emits [loading, ready] with category and summary',
    setUp: () => when(() => suggestCategory(any())).thenAnswer(
      (_) async => const Right(
        CategorySuggestionEntity(
          category: RequestCategoryEnum.exam,
          summary: 'Exame.',
        ),
      ),
    ),
    build: build,
    act: (b) =>
        b.add(const CreateSuggestionRequested('descrição longa o suficiente')),
    expect: () => [
      isA<CreateRequestState>().having(
        (s) => s.suggestionStatus,
        'suggestion',
        SuggestionStatus.loading,
      ),
      isA<CreateRequestState>()
          .having(
            (s) => s.suggestionStatus,
            'suggestion',
            SuggestionStatus.ready,
          )
          .having(
            (s) => s.suggestedCategory,
            'category',
            RequestCategoryEnum.exam,
          )
          .having((s) => s.suggestedSummary, 'summary', 'Exame.'),
    ],
  );

  blocTest<CreateRequestBloc, CreateRequestState>(
    'submit success emits [submitting, success]',
    setUp: () =>
        when(() => createRequest(any())).thenAnswer((_) async => Right(req())),
    build: build,
    act: (b) => b.add(
      const CreateSubmitted(
        title: 'Reagendar',
        description: 'descrição longa o suficiente',
        category: RequestCategoryEnum.appointment,
        priority: RequestPriorityEnum.high,
      ),
    ),
    expect: () => [
      isA<CreateRequestState>().having(
        (s) => s.status,
        'status',
        CreateStatus.submitting,
      ),
      isA<CreateRequestState>()
          .having((s) => s.status, 'status', CreateStatus.success)
          .having((s) => s.created, 'created', isNotNull),
    ],
  );

  blocTest<CreateRequestBloc, CreateRequestState>(
    'submit validation failure emits [submitting, failure]',
    setUp: () => when(() => createRequest(any())).thenAnswer(
      (_) async => const Left(ValidationFailure('título obrigatório')),
    ),
    build: build,
    act: (b) => b.add(
      const CreateSubmitted(
        title: '',
        description: 'descrição longa o suficiente',
        category: RequestCategoryEnum.appointment,
        priority: RequestPriorityEnum.high,
      ),
    ),
    expect: () => [
      isA<CreateRequestState>().having(
        (s) => s.status,
        'status',
        CreateStatus.submitting,
      ),
      isA<CreateRequestState>()
          .having((s) => s.status, 'status', CreateStatus.failure)
          .having((s) => s.errorMessage, 'error', 'título obrigatório'),
    ],
  );
}
