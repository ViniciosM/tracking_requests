class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException({this.message = 'Erro no Servidor.', this.statusCode});
}

class CacheException implements Exception {
  final String message;
  const CacheException({this.message = 'Erro de cache.'});
}

class NetworkException implements Exception {
  final String message;
  const NetworkException({this.message = 'Sem conexão com a internet.'});
}

class AuthException implements Exception {
  final String message;
  const AuthException({this.message = 'Autenticação falhou.'});
}
