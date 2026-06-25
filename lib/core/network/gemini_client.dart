import 'package:dio/dio.dart';

class GeminiClient {
  static Dio create({
    required String apiKey,
    String baseUrl = 'https://generativelanguage.googleapis.com',
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        contentType: Headers.jsonContentType,
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.queryParameters = {...options.queryParameters, 'key': apiKey};
          handler.next(options);
        },
      ),
    );
    return dio;
  }
}
