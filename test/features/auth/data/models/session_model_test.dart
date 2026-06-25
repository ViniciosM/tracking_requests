import 'package:flutter_test/flutter_test.dart';
import 'package:tracking_requests/features/auth/data/models/session_model.dart';

void main() {
  const tModel = SessionModel(
    token: 'jwt-123',
    userId: '1',
    userName: 'Maria Souza',
    email: 'user@email.com',
  );

  test('is a subtype of the Session entity', () {
    // Assert
    expect(tModel, isA<SessionModel>());
  });

  test('parses the login response (nested user object)', () {
    // Arrange
    final json = {
      'token': 'jwt-123',
      'user': {'id': 1, 'name': 'Maria Souza', 'email': 'user@email.com'},
    };

    // Act
    final result = SessionModel.fromLoginResponse(json);

    // Assert
    expect(result, tModel);
    expect(result.userId, '1');
  });

  test('round-trips through the cache JSON', () {
    // Act
    final restored = SessionModel.fromCacheJson(tModel.toCacheJson());

    // Assert
    expect(restored, tModel);
  });
}
