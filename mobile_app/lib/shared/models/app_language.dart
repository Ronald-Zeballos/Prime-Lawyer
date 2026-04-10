enum AppLanguage {
  english('en'),
  spanish('es');

  const AppLanguage(this.code);

  final String code;

  static AppLanguage fromCode(String? code) {
    for (final language in AppLanguage.values) {
      if (language.code == code) {
        return language;
      }
    }

    return AppLanguage.english;
  }
}
