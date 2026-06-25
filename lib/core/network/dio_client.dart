import 'package:dio/dio.dart';
import 'package:tracking_requests/core/storage/secure_storage_service.dart';

import '../constants/app_constants.dart';
import 'auth_interceptor.dart';

class DioClient {
  static Dio create({
    required SecureStorageService storage,
    String baseUrl = ApiConstants.baseUrl,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        contentType: Headers.jsonContentType,
        validateStatus: (status) => status != null && status < 400,
      ),
    );
    dio.interceptors.add(AuthInterceptor(storage));
    return dio;
  }
}
