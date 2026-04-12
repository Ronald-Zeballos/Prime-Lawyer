import '../../../../shared/models/session_user.dart';
import '../../domain/entities/user_profile.dart';
import '../models/profile_user_model.dart';

class ProfileUserMapper {
  const ProfileUserMapper._();

  static UserProfile toDomain(ProfileUserModel model) {
    return UserProfile(
      id: model.id,
      email: model.email,
      displayName: model.displayName,
      firstName: model.firstName,
      lastName: model.lastName,
      bio: model.bio,
      role: model.role,
      type: model.type,
      plan: model.plan,
      tokensAvailable: model.tokensAvailable,
      isActive: model.isActive,
    );
  }

  static SessionUser toSessionUser(UserProfile profile) {
    return SessionUser(
      id: profile.id,
      email: profile.email,
      displayName: profile.displayName,
      firstName: profile.firstName,
      lastName: profile.lastName,
      bio: profile.bio,
      role: profile.role,
      type: profile.type,
      plan: profile.plan,
      tokensAvailable: profile.tokensAvailable,
      isActive: profile.isActive,
    );
  }
}
