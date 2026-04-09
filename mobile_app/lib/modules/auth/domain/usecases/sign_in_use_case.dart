import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class SignInUseCase {
  const SignInUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<AuthSession> execute({
    required String email,
    required String password,
  }) {
    return _authRepository.signIn(
      email: email,
      password: password,
    );
  }
}
