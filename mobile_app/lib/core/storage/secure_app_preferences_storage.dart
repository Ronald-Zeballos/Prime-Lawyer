import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'app_preferences_storage.dart';

class SecureAppPreferencesStorage implements AppPreferencesStorage {
  SecureAppPreferencesStorage({
    FlutterSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _languageCodeKey = 'prime_lawyer_language_code';

  final FlutterSecureStorage _secureStorage;

  @override
  Future<String?> readLanguageCode() {
    return _secureStorage.read(key: _languageCodeKey);
  }

  @override
  Future<void> saveLanguageCode(String languageCode) {
    return _secureStorage.write(
      key: _languageCodeKey,
      value: languageCode,
    );
  }
}
