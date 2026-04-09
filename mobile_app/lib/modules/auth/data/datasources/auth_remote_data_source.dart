import '../../../../core/network/api_client.dart';
import '../models/auth_session_model.dart';

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
}
