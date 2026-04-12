import '../../../../shared/models/session_user.dart';
import '../../domain/entities/auth_user.dart';
import '../models/auth_user_model.dart';

class AuthUserMapper {
  const AuthUserMapper._();

  static AuthUser toDomain(AuthUserModel model) {
    return AuthUser(
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

  static SessionUser toSessionUser(AuthUser user) {
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
}
