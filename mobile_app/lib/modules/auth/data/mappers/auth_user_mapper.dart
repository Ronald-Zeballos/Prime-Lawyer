import '../../../../shared/models/session_user.dart';
import '../../domain/entities/auth_user.dart';
import '../models/auth_user_model.dart';

class AuthUserMapper {
  const AuthUserMapper._();

  static AuthUser toDomain(AuthUserModel model) {
    return AuthUser(
      id: model.id,
      email: model.email,
      firstName: model.firstName,
      lastName: model.lastName,
      role: model.role,
    );
  }

  static SessionUser toSessionUser(AuthUser user) {
    return SessionUser(
      id: user.id,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      role: user.role,
    );
  }
}
