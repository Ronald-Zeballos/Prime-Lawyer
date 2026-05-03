import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class GetAuthenticatedUserUseCase {
  const GetAuthenticatedUserUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthUser> execute() {
    return _repository.getAuthenticatedUser();
  }
}
