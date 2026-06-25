import 'package:dio/dio.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/session_model.dart';

abstract class AuthRemoteDataSource {
  Future<SessionModel> login({required String email, required String password});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<SessionModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      return SessionModel.fromLoginResponse(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException(
          message: _serverMessage(e) ?? 'E-mail ou senha inválidos.',
        );
      }
      if (_isConnectionIssue(e)) {
        throw const NetworkException();
      }
      throw ServerException(
        message: _serverMessage(e) ?? 'Não foi possível autenticar.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  bool _isConnectionIssue(DioException e) =>
      e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.sendTimeout;

  String? _serverMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic> && data['message'] is String) {
      return data['message'] as String;
    }
    return null;
  }
}
