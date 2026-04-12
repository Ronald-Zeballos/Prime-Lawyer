import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../mappers/profile_user_mapper.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._remoteDataSource);

  final ProfileRemoteDataSource _remoteDataSource;

  @override
  Future<UserProfile> getMyProfile() async {
    final profile = await _remoteDataSource.getMyProfile();

    return ProfileUserMapper.toDomain(profile);
  }

  @override
  Future<UserProfile> updateMyProfile(UpdateMyProfileInput input) async {
    final profile = await _remoteDataSource.updateMyProfile(
      displayName: input.displayName,
      firstName: input.firstName,
      lastName: input.lastName,
      bio: input.bio,
    );

    return ProfileUserMapper.toDomain(profile);
  }
}
