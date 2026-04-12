import '../entities/user_profile.dart';

class UpdateMyProfileInput {
  const UpdateMyProfileInput({
    this.displayName,
    this.firstName,
    this.lastName,
    this.bio,
  });

  final String? displayName;
  final String? firstName;
  final String? lastName;
  final String? bio;
}

abstract class ProfileRepository {
  Future<UserProfile> getMyProfile();
  Future<UserProfile> updateMyProfile(UpdateMyProfileInput input);
}
