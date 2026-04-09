import 'package:flutter/foundation.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../shared/providers/session_provider.dart';
import '../../data/mappers/auth_user_mapper.dart';
import '../../domain/usecases/sign_in_use_case.dart';

class AuthController extends ChangeNotifier {
  AuthController({
    required SignInUseCase signInUseCase,
    required SessionProvider sessionProvider,
  })  : _signInUseCase = signInUseCase,
        _sessionProvider = sessionProvider;

  final SignInUseCase _signInUseCase;
  final SessionProvider _sessionProvider;

  bool _isSubmitting = false;
  String? _errorMessage;

  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final session = await _signInUseCase.execute(
        email: email.trim(),
        password: password,
      );

      await _sessionProvider.setAuthenticatedSession(
        accessToken: session.accessToken,
        user: AuthUserMapper.toSessionUser(session.user),
      );

      _isSubmitting = false;
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage =
          'We could not sign in right now. Please try again in a moment.';
    }

    _isSubmitting = false;
    notifyListeners();
    return false;
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    notifyListeners();
  }
}
