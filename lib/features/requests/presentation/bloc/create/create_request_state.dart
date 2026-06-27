import 'package:equatable/equatable.dart';
import 'package:tracking_requests/features/requests/domain/entities/request_entity.dart';

enum CreateStatus { editing, submitting, success, failure }

enum SuggestionStatus { idle, loading, ready, failure }

class CreateRequestState extends Equatable {
  final CreateStatus status;
  final SuggestionStatus suggestionStatus;
  final String? suggestedDescription;
  final RequestEntity? created;
  final String? errorMessage;

  const CreateRequestState({
    this.status = CreateStatus.editing,
    this.suggestionStatus = SuggestionStatus.idle,
    this.suggestedDescription,
    this.created,
    this.errorMessage,
  });

  CreateRequestState copyWith({
    CreateStatus? status,
    SuggestionStatus? suggestionStatus,
    String? suggestedDescription,
    RequestEntity? created,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CreateRequestState(
      status: status ?? this.status,
      suggestionStatus: suggestionStatus ?? this.suggestionStatus,
      suggestedDescription: suggestedDescription ?? this.suggestedDescription,
      created: created ?? this.created,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    suggestionStatus,
    suggestedDescription,
    created,
    errorMessage,
  ];
}
