abstract class AppPreferencesStorage {
  Future<String?> readLanguageCode();
  Future<String?> readApiBaseUrl();

  Future<void> saveLanguageCode(String languageCode);
  Future<void> saveApiBaseUrl(String apiBaseUrl);
  Future<void> clearApiBaseUrl();
}
