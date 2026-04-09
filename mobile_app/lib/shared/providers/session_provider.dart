import 'package:flutter/foundation.dart';

import '../../core/services/session_service.dart';
import '../models/session_user.dart';

enum SessionStatus {
  initializing,
  authenticated,
  unauthenticated,
}

class SessionProvider extends ChangeNotifier {
  SessionProvider({
    required SessionService sessionService,
  }) : _sessionService = sessionService;

  final SessionService _sessionService;

  SessionStatus _status = SessionStatus.initializing;
  String? _accessToken;
  SessionUser? _currentUser;

  SessionStatus get status => _status;
  String? get accessToken => _accessToken;
  SessionUser? get currentUser => _currentUser;
  bool get isAuthenticated => _status == SessionStatus.authenticated;

  Future<void> bootstrap() async {
    _status = SessionStatus.initializing;
    notifyListeners();

    _accessToken = await _sessionService.restoreAccessToken();
    _status = _accessToken == null || _accessToken!.isEmpty
        ? SessionStatus.unauthenticated
        : SessionStatus.authenticated;
    _currentUser = null;

    notifyListeners();
  }

  Future<void> setAuthenticatedSession({
    required String accessToken,
    required SessionUser user,
  }) async {
    await _sessionService.persistAccessToken(accessToken);
    _accessToken = accessToken;
    _currentUser = user;
    _status = SessionStatus.authenticated;
    notifyListeners();
  }

  Future<void> clearSession() async {
    await _sessionService.clearAccessToken();
    _accessToken = null;
    _currentUser = null;
    _status = SessionStatus.unauthenticated;
    notifyListeners();
  }
}
