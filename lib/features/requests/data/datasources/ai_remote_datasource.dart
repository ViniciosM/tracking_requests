import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../models/description_suggestion_model.dart';

abstract class AiRemoteDataSource {
  Future<DescriptionSuggestionModel> suggestDescription(String title);
}

class GeminiAiRemoteDataSource implements AiRemoteDataSource {
  final Dio dio;
  final String model;
  GeminiAiRemoteDataSource({
    required this.dio,
    this.model = 'gemini-2.5-flash',
  });

  @override
  Future<DescriptionSuggestionModel> suggestDescription(String title) async {
    try {
      final response = await dio.post(
        '/v1beta/models/$model:generateContent',
        data: {
          'contents': [
            {
              'parts': [
                {'text': _buildPrompt(title)},
              ],
            },
          ],
          'generationConfig': {
            'responseMimeType': 'application/json',
            'temperature': 0.4,
          },
        },
      );
      return DescriptionSuggestionModel.fromAiJson(_extractText(response.data));
    } on DioException catch (e) {
      final isConnectionIssue =
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout;
      if (isConnectionIssue) throw const NetworkException();

      if (e.response?.statusCode == 429) {
        throw const ServerException(
          message:
              'Limite de sugestões atingido. Aguarde alguns segundos e tente novamente.',
        );
      }
      throw ServerException(
        message: 'Falha ao consultar a IA.',
        statusCode: e.response?.statusCode,
      );
    } on FormatException {
      throw const ServerException(message: 'Resposta inválida da IA.');
    }
  }

  String _buildPrompt(String title) {
    return 'You are an assistant for a healthcare service-request app. '
        'Given a short request TITLE, write a clear and polite request '
        'DESCRIPTION in Brazilian Portuguese, in the first person, with 2 to 3 '
        'sentences, expanding the title into a complete description the user can '
        'review and edit. Respond ONLY with a JSON object of the form '
        '{"description": <text>}. Title: "$title"';
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
