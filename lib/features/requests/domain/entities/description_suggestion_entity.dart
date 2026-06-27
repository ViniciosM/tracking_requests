import 'package:equatable/equatable.dart';

class DescriptionSuggestionEntity extends Equatable {
  final String description;

  const DescriptionSuggestionEntity({required this.description});

  @override
  List<Object?> get props => [description];
}
