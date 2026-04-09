import '../storage/token_storage.dart';

class SessionService {
  SessionService({
    required TokenStorage tokenStorage,
  }) : _tokenStorage = tokenStorage;

  final TokenStorage _tokenStorage;

  Future<String?> restoreAccessToken() {
    return _tokenStorage.readAccessToken();
  }

  Future<void> persistAccessToken(String accessToken) {
    return _tokenStorage.saveAccessToken(accessToken);
  }

  Future<void> clearAccessToken() {
    return _tokenStorage.clearAccessToken();
  }
}
