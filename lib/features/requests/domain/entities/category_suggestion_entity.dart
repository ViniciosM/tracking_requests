import 'package:equatable/equatable.dart';
import 'package:tracking_requests/core/enums/request_category_enum.dart';

class CategorySuggestionEntity extends Equatable {
  final RequestCategoryEnum category;
  final String summary;

  const CategorySuggestionEntity({
    required this.category,
    required this.summary,
  });

  @override
  List<Object?> get props => [category, summary];
}
