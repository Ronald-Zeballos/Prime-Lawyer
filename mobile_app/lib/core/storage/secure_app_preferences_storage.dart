import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'app_preferences_storage.dart';

class SecureAppPreferencesStorage implements AppPreferencesStorage {
  SecureAppPreferencesStorage({
    FlutterSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _languageCodeKey = 'prime_lawyer_language_code';
  static const _apiBaseUrlKey = 'prime_lawyer_api_base_url';

  final FlutterSecureStorage _secureStorage;

  @override
  Future<String?> readLanguageCode() {
    return _secureStorage.read(key: _languageCodeKey);
  }

  @override
  Future<String?> readApiBaseUrl() {
    return _secureStorage.read(key: _apiBaseUrlKey);
  }

  @override
  Future<void> saveLanguageCode(String languageCode) {
    return _secureStorage.write(
      key: _languageCodeKey,
      value: languageCode,
    );
  }

  @override
  Future<void> saveApiBaseUrl(String apiBaseUrl) {
    return _secureStorage.write(
      key: _apiBaseUrlKey,
      value: apiBaseUrl,
    );
  }

  @override
  Future<void> clearApiBaseUrl() {
    return _secureStorage.delete(key: _apiBaseUrlKey);
  }
}
