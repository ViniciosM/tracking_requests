import 'package:dio/dio.dart';
import 'package:tracking_requests/core/enums/request_category_enum.dart';
import '../../../../core/error/exceptions.dart';
import '../models/category_suggestion_model.dart';

abstract class AiRemoteDataSource {
  Future<CategorySuggestionModel> suggestCategory(String description);
}

class GeminiAiRemoteDataSource implements AiRemoteDataSource {
  final Dio dio;
  final String model;
  GeminiAiRemoteDataSource({
    required this.dio,
    this.model = 'gemini-flash-latest',
  });

  @override
  Future<CategorySuggestionModel> suggestCategory(String description) async {
    try {
      final response = await dio.post(
        '/v1beta/models/$model:generateContent',
        data: {
          'contents': [
            {
              'parts': [
                {'text': _buildPrompt(description)},
              ],
            },
          ],
          'generationConfig': {
            'responseMimeType': 'application/json',
            'temperature': 0.2,
          },
        },
      );
      return CategorySuggestionModel.fromAiJson(_extractText(response.data));
    } on DioException catch (e) {
      final isConnectionIssue =
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout;
      if (isConnectionIssue) throw const NetworkException();
      throw ServerException(
        message: 'Falha ao consultar a IA.',
        statusCode: e.response?.statusCode,
      );
    } on FormatException {
      throw const ServerException(message: 'Resposta inválida da IA.');
    }
  }

  String _buildPrompt(String description) {
    final categories = RequestCategoryEnum.values
        .map((c) => c.apiValue)
        .join(', ');
    return 'You are a triage assistant for a healthcare service-request app. '
        'Read the request description and respond ONLY with a JSON object of the '
        'form {"category": <one of: $categories>, "summary": <a concise '
        'one-sentence summary in Brazilian Portuguese>}. '
        'Description: "$description"';
  }

  String _extractText(dynamic data) {
    final candidates = (data as Map<String, dynamic>)['candidates'] as List;
    final content =
        (candidates.first as Map<String, dynamic>)['content']
            as Map<String, dynamic>;
    final parts = content['parts'] as List;
    return (parts.first as Map<String, dynamic>)['text'] as String;
  }
}
