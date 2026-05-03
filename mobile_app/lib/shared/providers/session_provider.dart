import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/errors/api_exception.dart';
import '../../core/services/session_service.dart';
import '../../modules/auth/domain/entities/auth_user.dart';
import '../../modules/auth/domain/usecases/get_authenticated_user_use_case.dart';
import '../models/session_user.dart';

enum SessionStatus {
  initializing,
  authenticated,
  unauthenticated,
}

class SessionProvider extends ChangeNotifier {
  SessionProvider({
    required SessionService sessionService,
    required GetAuthenticatedUserUseCase getAuthenticatedUserUseCase,
  })  : _sessionService = sessionService,
        _getAuthenticatedUserUseCase = getAuthenticatedUserUseCase {
    _sessionInvalidatedSubscription =
        _sessionService.sessionInvalidatedStream.listen((_) {
      _setUnauthenticated(notify: true);
    });
  }

  final SessionService _sessionService;
  final GetAuthenticatedUserUseCase _getAuthenticatedUserUseCase;
  late final StreamSubscription<void> _sessionInvalidatedSubscription;

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

    if (_accessToken == null || _accessToken!.isEmpty) {
      _setUnauthenticated(notify: false);
      notifyListeners();
      return;
    }

    try {
      final user = await _getAuthenticatedUserUseCase.execute();
      _currentUser = _toSessionUser(user);
      _status = SessionStatus.authenticated;
    } on ApiException catch (error) {
      if (error.statusCode == 401) {
        await _sessionService.clearAccessToken();
        _setUnauthenticated(notify: false);
      } else {
        _currentUser = null;
        _status = SessionStatus.authenticated;
      }
    } catch (_) {
      _currentUser = null;
      _status = SessionStatus.authenticated;
    }

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

  void syncCurrentUser(SessionUser user) {
    _currentUser = user;
    notifyListeners();
  }

  Future<void> clearSession() async {
    await _sessionService.clearAccessToken();
    _setUnauthenticated(notify: true);
  }

  SessionUser _toSessionUser(AuthUser user) {
    return SessionUser(
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      firstName: user.firstName,
      lastName: user.lastName,
      bio: user.bio,
      role: user.role,
      type: user.type,
      plan: user.plan,
      tokensAvailable: user.tokensAvailable,
      isActive: user.isActive,
    );
  }

  void _setUnauthenticated({
    required bool notify,
  }) {
    _accessToken = null;
    _currentUser = null;
    _status = SessionStatus.unauthenticated;

    if (notify) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sessionInvalidatedSubscription.cancel();
    super.dispose();
  }
}
