abstract class AppPreferencesStorage {
  Future<String?> readLanguageCode();
  Future<String?> readApiBaseUrl();
  Future<String?> readLastLocalNetworkApiBaseUrl();

  Future<void> saveLanguageCode(String languageCode);
  Future<void> saveApiBaseUrl(String apiBaseUrl);
  Future<void> saveLastLocalNetworkApiBaseUrl(String apiBaseUrl);
  Future<void> clearApiBaseUrl();
  Future<void> clearLastLocalNetworkApiBaseUrl();
}
