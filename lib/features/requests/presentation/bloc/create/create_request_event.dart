import 'package:equatable/equatable.dart';
import 'package:tracking_requests/core/enums/request_category_enum.dart';
import 'package:tracking_requests/core/enums/request_priority_enum.dart';

sealed class CreateRequestEvent extends Equatable {
  const CreateRequestEvent();
  @override
  List<Object?> get props => [];
}

class CreateSuggestionRequested extends CreateRequestEvent {
  final String description;
  const CreateSuggestionRequested(this.description);
  @override
  List<Object?> get props => [description];
}

class CreateSubmitted extends CreateRequestEvent {
  final String title;
  final String description;
  final RequestCategoryEnum category;
  final RequestPriorityEnum priority;
  const CreateSubmitted({
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
  });
  @override
  List<Object?> get props => [title, description, category, priority];
}
