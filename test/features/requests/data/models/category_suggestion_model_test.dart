import 'package:flutter_test/flutter_test.dart';
import 'package:tracking_requests/core/enums/request_category_enum.dart';
import 'package:tracking_requests/features/requests/data/models/category_suggestion_model.dart';

void main() {
  test('parses the LLM JSON into a typed suggestion', () {
    // Arrange
    const raw =
        '{"category": "exam", "summary": "Pedido de exame de sangue. "}';

    // Act
    final result = CategorySuggestionModel.fromAiJson(raw);

    // Assert
    expect(result.category, RequestCategoryEnum.exam);
    expect(result.summary, 'Pedido de exame de sangue.'); // trimmed
  });

  test('falls back to general for an unknown category', () {
    // Arrange
    const raw = '{"category": "unknown", "summary": "x"}';

    // Act
    final result = CategorySuggestionModel.fromAiJson(raw);

    // Assert
    expect(result.category, RequestCategoryEnum.general);
  });
}
