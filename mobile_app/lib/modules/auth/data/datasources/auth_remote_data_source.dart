import '../../../../core/network/api_client.dart';
import '../models/auth_session_model.dart';
import '../models/auth_user_model.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<AuthSessionModel> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.postJson(
      '/auth/login',
      authenticated: false,
      body: {
        'email': email,
        'password': password,
      },
    );

    return AuthSessionModel.fromJson(response as Map<String, dynamic>);
  }

  Future<AuthUserModel> getAuthenticatedUser() async {
    final response = await _apiClient.get('/auth/me');
    final user =
        (response as Map<String, dynamic>)['user'] as Map<String, dynamic>;

    return AuthUserModel.fromJson(user);
  }
}
