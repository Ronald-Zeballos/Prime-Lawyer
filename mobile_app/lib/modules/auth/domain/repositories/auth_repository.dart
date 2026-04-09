import '../entities/auth_session.dart';

abstract class AuthRepository {
  Future<AuthSession> signIn({
    required String email,
    required String password,
  });
}
