import '../entities/auth_user.dart';
import '../entities/auth_session.dart';

abstract class AuthRepository {
  Future<AuthSession> signIn({
    required String email,
    required String password,
  });

  Future<AuthUser> getAuthenticatedUser();
}
