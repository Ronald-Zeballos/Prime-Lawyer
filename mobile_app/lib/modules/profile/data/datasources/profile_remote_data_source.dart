import '../../../../core/network/api_client.dart';
import '../models/profile_user_model.dart';

class ProfileRemoteDataSource {
  const ProfileRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<ProfileUserModel> getMyProfile() async {
    final response = await _apiClient.get('/profile/me');
    final user =
        (response as Map<String, dynamic>)['user'] as Map<String, dynamic>;

    return ProfileUserModel.fromJson(user);
  }

  Future<ProfileUserModel> updateMyProfile({
    String? displayName,
    String? firstName,
    String? lastName,
    String? bio,
  }) async {
    final response = await _apiClient.patchJson(
      '/profile/me',
      body: {
        if (displayName != null) 'displayName': displayName,
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (bio != null) 'bio': bio,
      },
    );
    final user =
        (response as Map<String, dynamic>)['user'] as Map<String, dynamic>;

    return ProfileUserModel.fromJson(user);
  }
}
