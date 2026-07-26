class ServerException implements Exception {
  const ServerException([
    this.message = 'Server exception',
    this.statusCode,
  ]);

  final String message;
  final int? statusCode;
}

class AuthException implements Exception {
  const AuthException([this.message = 'Authentication failed']);

  final String message;
}

class NetworkException implements Exception {
  const NetworkException([this.message = 'No internet connection']);

  final String message;
}

class CacheException implements Exception {
  const CacheException([this.message = 'Cache exception']);

  final String message;
}
