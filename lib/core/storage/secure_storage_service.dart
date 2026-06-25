import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class SecureStorageService {
  Future<void> writeToken(String token);
  Future<String?> readToken();
  Future<void> writeUser(String userJson);
  Future<String?> readUser();
  Future<void> clear();
}

class FlutterSecureStorageService implements SecureStorageService {
  final FlutterSecureStorage _storage;
  FlutterSecureStorageService([FlutterSecureStorage? storage])
    : _storage =
          storage ?? const FlutterSecureStorage(aOptions: AndroidOptions());

  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  @override
  Future<void> writeToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  @override
  Future<String?> readToken() => _storage.read(key: _tokenKey);

  @override
  Future<void> writeUser(String userJson) =>
      _storage.write(key: _userKey, value: userJson);

  @override
  Future<String?> readUser() => _storage.read(key: _userKey);

  @override
  Future<void> clear() => _storage.deleteAll();
}
