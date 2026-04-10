import 'package:flutter/foundation.dart';

import '../../core/storage/app_preferences_storage.dart';
import '../localization/app_strings.dart';
import '../models/app_language.dart';

class AppLanguageProvider extends ChangeNotifier {
  AppLanguageProvider({
    required AppPreferencesStorage preferencesStorage,
  }) : _preferencesStorage = preferencesStorage;

  final AppPreferencesStorage _preferencesStorage;

  AppLanguage _currentLanguage = AppLanguage.english;

  AppLanguage get currentLanguage => _currentLanguage;
  AppStrings get strings => AppStrings(_currentLanguage);

  Future<void> bootstrap() async {
    final storedLanguageCode = await _preferencesStorage.readLanguageCode();
    _currentLanguage = AppLanguage.fromCode(storedLanguageCode);
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (_currentLanguage == language) {
      return;
    }

    _currentLanguage = language;
    notifyListeners();
    await _preferencesStorage.saveLanguageCode(language.code);
  }
}
