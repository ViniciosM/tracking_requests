import 'package:dio/dio.dart';
import 'package:tracking_requests/core/storage/secure_storage_service.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService storage;
  AuthInterceptor(this.storage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await storage.readToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
