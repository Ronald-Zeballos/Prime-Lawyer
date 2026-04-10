abstract class AppPreferencesStorage {
  Future<String?> readLanguageCode();

  Future<void> saveLanguageCode(String languageCode);
}
