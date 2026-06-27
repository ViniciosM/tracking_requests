import 'dart:convert';

import 'package:tracking_requests/features/requests/domain/entities/description_suggestion_entity.dart';

class DescriptionSuggestionModel extends DescriptionSuggestionEntity {
  const DescriptionSuggestionModel({required super.description});

  factory DescriptionSuggestionModel.fromAiJson(String jsonText) {
    final map = jsonDecode(jsonText) as Map<String, dynamic>;
    return DescriptionSuggestionModel(
      description: (map['description'] as String).trim(),
    );
  }
}
