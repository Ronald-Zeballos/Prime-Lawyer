abstract class AppPreferencesStorage {
  Future<String?> readLanguageCode();
  Future<String?> readApiBaseUrl();
  Future<String?> readAutoDetectedApiBaseUrl();

  Future<void> saveLanguageCode(String languageCode);
  Future<void> saveApiBaseUrl(String apiBaseUrl);
  Future<void> saveAutoDetectedApiBaseUrl(String apiBaseUrl);
  Future<void> clearApiBaseUrl();
  Future<void> clearAutoDetectedApiBaseUrl();
}
