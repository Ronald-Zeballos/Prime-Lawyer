import 'dart:async';

import '../storage/token_storage.dart';

class SessionService {
  SessionService({
    required TokenStorage tokenStorage,
  }) : _tokenStorage = tokenStorage;

  final TokenStorage _tokenStorage;
  final StreamController<void> _sessionInvalidatedController =
      StreamController<void>.broadcast();

  Stream<void> get sessionInvalidatedStream =>
      _sessionInvalidatedController.stream;

  Future<String?> restoreAccessToken() {
    return _tokenStorage.readAccessToken();
  }

  Future<void> persistAccessToken(String accessToken) {
    return _tokenStorage.saveAccessToken(accessToken);
  }

  Future<void> clearAccessToken() {
    return _tokenStorage.clearAccessToken();
  }

  Future<void> invalidateSession() async {
    await _tokenStorage.clearAccessToken();
    _sessionInvalidatedController.add(null);
  }

  void dispose() {
    _sessionInvalidatedController.close();
  }
}
