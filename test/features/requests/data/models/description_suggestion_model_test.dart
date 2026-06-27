import 'package:flutter_test/flutter_test.dart';
import 'package:tracking_requests/features/requests/data/models/description_suggestion_model.dart';

void main() {
  test('parses the LLM JSON into a typed description suggestion', () {
    const raw = '{"description": "Pedido de exame de sangue de rotina.  "}';

    final result = DescriptionSuggestionModel.fromAiJson(raw);

    expect(result.description, 'Pedido de exame de sangue de rotina.');
  });
}
