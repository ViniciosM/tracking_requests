import 'dart:convert';

import 'package:tracking_requests/core/enums/request_category_enum.dart';
import 'package:tracking_requests/features/requests/domain/entities/category_suggestion_entity.dart';

class CategorySuggestionModel extends CategorySuggestionEntity {
  const CategorySuggestionModel({
    required super.category,
    required super.summary,
  });

  factory CategorySuggestionModel.fromAiJson(String jsonText) {
    final map = jsonDecode(jsonText) as Map<String, dynamic>;
    return CategorySuggestionModel(
      category: RequestCategoryEnum.fromApi(map['category'] as String),
      summary: (map['summary'] as String).trim(),
    );
  }
}
