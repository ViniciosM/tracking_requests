import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracking_requests/core/error/exceptions.dart';
import 'package:tracking_requests/features/auth/data/datasources/auth_remote_datasource.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late AuthRemoteDataSourceImpl dataSource;
  late MockDio dio;

  setUp(() {
    dio = MockDio();
    dataSource = AuthRemoteDataSourceImpl(dio);
  });

  final options = RequestOptions(path: '/login');

  test('returns a SessionModel on a successful login', () async {
    // Act
    when(() => dio.post(any(), data: any(named: 'data'))).thenAnswer(
      (_) async => Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'token': 'jwt-123',
          'user': {'id': '1', 'name': 'Maria Souza', 'email': 'user@email.com'},
        },
      ),
    );

    final result = await dataSource.login(
      email: 'user@email.com',
      password: 'password123',
    );

    // Assert
    expect(result.token, 'jwt-123');
    expect(result.userName, 'Maria Souza');
  });

  test('throws AuthException on 401', () async {
    // Act
    when(() => dio.post(any(), data: any(named: 'data'))).thenThrow(
      DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: options,
          statusCode: 401,
          data: {'message': 'E-mail ou senha inválidos.'},
        ),
      ),
    );

    // Assert
    await expectLater(
      dataSource.login(email: 'x@y.com', password: 'wrong'),
      throwsA(isA<AuthException>()),
    );
  });

  test('throws NetworkException on a connection error', () async {
    // Act
    when(() => dio.post(any(), data: any(named: 'data'))).thenThrow(
      DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      ),
    );

    // Assert
    await expectLater(
      dataSource.login(email: 'x@y.com', password: 'p'),
      throwsA(isA<NetworkException>()),
    );
  });
}
