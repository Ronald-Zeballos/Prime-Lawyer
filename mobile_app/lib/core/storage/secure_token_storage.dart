import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'token_storage.dart';

class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage({
    FlutterSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'prime_lawyer_access_token';

  final FlutterSecureStorage _secureStorage;

  @override
  Future<void> clearAccessToken() {
    return _secureStorage.delete(key: _accessTokenKey);
  }

  @override
  Future<String?> readAccessToken() {
    return _secureStorage.read(key: _accessTokenKey);
  }

  @override
  Future<void> saveAccessToken(String token) {
    return _secureStorage.write(key: _accessTokenKey, value: token);
  }
}
