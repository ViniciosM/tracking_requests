import 'package:bloc/bloc.dart';
import 'package:tracking_requests/features/requests/domain/usecases/create_request_usecase.dart';
import 'package:tracking_requests/features/requests/domain/usecases/suggest_category_usecase.dart';
import 'package:tracking_requests/features/requests/presentation/bloc/create/create_request_event.dart';
import 'package:tracking_requests/features/requests/presentation/bloc/create/create_request_state.dart';

class CreateRequestBloc extends Bloc<CreateRequestEvent, CreateRequestState> {
  final CreateRequestUseCase createRequest;
  final SuggestCategoryUseCase suggestCategory;

  CreateRequestBloc({
    required this.createRequest,
    required this.suggestCategory,
  }) : super(const CreateRequestState()) {
    on<CreateSuggestionRequested>(_onSuggestion);
    on<CreateSubmitted>(_onSubmit);
  }

  Future<void> _onSuggestion(
    CreateSuggestionRequested event,
    Emitter<CreateRequestState> emit,
  ) async {
    emit(state.copyWith(suggestionStatus: SuggestionStatus.loading));
    final result = await suggestCategory(
      SuggestCategoryParams(event.description),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          suggestionStatus: SuggestionStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (suggestion) => emit(
        state.copyWith(
          suggestionStatus: SuggestionStatus.ready,
          suggestedCategory: suggestion.category,
          suggestedSummary: suggestion.summary,
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onSubmit(
    CreateSubmitted event,
    Emitter<CreateRequestState> emit,
  ) async {
    emit(state.copyWith(status: CreateStatus.submitting, clearError: true));
    final result = await createRequest(
      CreateRequestParams(
        title: event.title,
        description: event.description,
        category: event.category,
        priority: event.priority,
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CreateStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (request) =>
          emit(state.copyWith(status: CreateStatus.success, created: request)),
    );
  }
}
