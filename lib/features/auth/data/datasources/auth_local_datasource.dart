import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/session_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheSession(SessionModel session);
  Future<SessionModel?> getSession();
  Future<void> clear();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureStorageService storage;
  AuthLocalDataSourceImpl(this.storage);

  @override
  Future<void> cacheSession(SessionModel session) async {
    try {
      await storage.writeToken(session.token);
      await storage.writeUser(session.toCacheJson());
    } catch (_) {
      throw const CacheException(message: 'Falha ao salvar a sessão.');
    }
  }

  @override
  Future<SessionModel?> getSession() async {
    try {
      final userJson = await storage.readUser();
      if (userJson == null) return null;
      return SessionModel.fromCacheJson(userJson);
    } catch (_) {
      throw const CacheException(message: 'Falha ao ler a sessão.');
    }
  }

  @override
  Future<void> clear() => storage.clear();
}
