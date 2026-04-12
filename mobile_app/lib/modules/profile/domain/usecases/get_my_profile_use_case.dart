import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class GetMyProfileUseCase {
  const GetMyProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<UserProfile> execute() {
    return _repository.getMyProfile();
  }
}
