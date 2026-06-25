import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracking_requests/core/network/auth_interceptor.dart';
import 'package:tracking_requests/core/storage/secure_storage_service.dart';

class MockSecureStorageService extends Mock implements SecureStorageService {}

class MockHandler extends Mock implements RequestInterceptorHandler {}

void main() {
  late MockSecureStorageService storage;
  late MockHandler handler;
  late AuthInterceptor interceptor;

  setUp(() {
    storage = MockSecureStorageService();
    handler = MockHandler();
    interceptor = AuthInterceptor(storage);
  });

  test('attaches the Bearer token when one is stored', () async {
    // Arrange
    when(() => storage.readToken()).thenAnswer((_) async => 'jwt-123');
    final options = RequestOptions(path: '/requests');

    // Act
    await interceptor.onRequest(options, handler);

    // Assert
    expect(options.headers['Authorization'], 'Bearer jwt-123');
    verify(() => handler.next(options)).called(1);
  });

  test('does not set the header when no token is stored', () async {
    // Arrange
    when(() => storage.readToken()).thenAnswer((_) async => null);
    final options = RequestOptions(path: '/requests');

    // Act
    await interceptor.onRequest(options, handler);

    // Assert
    expect(options.headers.containsKey('Authorization'), isFalse);
    verify(() => handler.next(options)).called(1);
  });
}
