import 'auth_user_model.dart';

class AuthSessionModel {
  const AuthSessionModel({
    required this.accessToken,
    required this.user,
  });

  final String accessToken;
  final AuthUserModel user;

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    return AuthSessionModel(
      accessToken: json['accessToken'] as String,
      user: AuthUserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
