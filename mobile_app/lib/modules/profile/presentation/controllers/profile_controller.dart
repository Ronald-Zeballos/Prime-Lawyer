import 'package:flutter/foundation.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../shared/providers/session_provider.dart';
import '../../data/mappers/profile_user_mapper.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/get_my_profile_use_case.dart';
import '../../domain/usecases/update_my_profile_use_case.dart';

class ProfileController extends ChangeNotifier {
  ProfileController({
    required GetMyProfileUseCase getMyProfileUseCase,
    required UpdateMyProfileUseCase updateMyProfileUseCase,
    required SessionProvider sessionProvider,
  })  : _getMyProfileUseCase = getMyProfileUseCase,
        _updateMyProfileUseCase = updateMyProfileUseCase,
        _sessionProvider = sessionProvider;

  final GetMyProfileUseCase _getMyProfileUseCase;
  final UpdateMyProfileUseCase _updateMyProfileUseCase;
  final SessionProvider _sessionProvider;

  UserProfile? _profile;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  Future<void> loadProfile({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final profile = await _getMyProfileUseCase.execute();
      _profile = profile;
      _sessionProvider.syncCurrentUser(
        ProfileUserMapper.toSessionUser(profile),
      );
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'We could not load your profile right now.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProfile(UpdateMyProfileInput input) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final profile = await _updateMyProfileUseCase.execute(input);
      _profile = profile;
      _sessionProvider.syncCurrentUser(
        ProfileUserMapper.toSessionUser(profile),
      );
      _isSaving = false;
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'We could not update your profile right now.';
    }

    _isSaving = false;
    notifyListeners();
    return false;
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    notifyListeners();
  }
}
