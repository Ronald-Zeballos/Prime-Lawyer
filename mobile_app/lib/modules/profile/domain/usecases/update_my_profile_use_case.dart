import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class UpdateMyProfileUseCase {
  const UpdateMyProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<UserProfile> execute(UpdateMyProfileInput input) {
    return _repository.updateMyProfile(input);
  }
}
