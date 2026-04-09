import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../mappers/auth_user_mapper.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    final sessionModel = await _remoteDataSource.signIn(
      email: email,
      password: password,
    );

    return AuthSession(
      accessToken: sessionModel.accessToken,
      user: AuthUserMapper.toDomain(sessionModel.user),
    );
  }
}
