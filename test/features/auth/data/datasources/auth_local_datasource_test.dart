import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracking_requests/core/storage/secure_storage_service.dart';
import 'package:tracking_requests/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:tracking_requests/features/auth/data/models/session_model.dart';

class MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  late AuthLocalDataSourceImpl dataSource;
  late MockSecureStorageService storage;

  setUp(() {
    storage = MockSecureStorageService();
    dataSource = AuthLocalDataSourceImpl(storage);
  });

  // Arrange
  const tModel = SessionModel(
    token: 'jwt-123',
    userId: '1',
    userName: 'Maria Souza',
    email: 'user@email.com',
  );

  test('caches the token and the user payload', () async {
    // Act
    when(() => storage.writeToken(any())).thenAnswer((_) async {});
    when(() => storage.writeUser(any())).thenAnswer((_) async {});

    await dataSource.cacheSession(tModel);

    // Assert
    verify(() => storage.writeToken('jwt-123')).called(1);
    verify(() => storage.writeUser(tModel.toCacheJson())).called(1);
  });

  test('returns the stored session when present', () async {
    // Act
    when(
      () => storage.readUser(),
    ).thenAnswer((_) async => tModel.toCacheJson());

    final result = await dataSource.getSession();

    // Assert
    expect(result, tModel);
  });

  test('returns null when there is no stored session', () async {
    // Act
    when(() => storage.readUser()).thenAnswer((_) async => null);

    final result = await dataSource.getSession();
    // Assert
    expect(result, isNull);
  });

  test('clear delegates to the storage', () async {
    // Act
    when(() => storage.clear()).thenAnswer((_) async {});

    await dataSource.clear();
    // Assert
    verify(() => storage.clear()).called(1);
  });
}
