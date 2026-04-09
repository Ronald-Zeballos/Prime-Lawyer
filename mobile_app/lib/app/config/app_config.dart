class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
  });

  static const String appName = 'Prime Lawyer';
  static const String defaultApiBaseUrl = 'http://10.0.2.2:3000/api/v1';

  final String apiBaseUrl;

  factory AppConfig.fromEnvironment() {
    return const AppConfig(
      apiBaseUrl: String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: defaultApiBaseUrl,
      ),
    );
  }
}
