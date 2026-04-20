class AppConfig {
  const AppConfig({
    required this.apiBaseUrlOverride,
  });

  static const String appName = 'Prime Lawyer';
  static const int defaultApiPort = 3000;
  static const String defaultApiPath = '/api/v1';

  final String? apiBaseUrlOverride;

  bool get hasApiBaseUrlOverride {
    final configuredValue = apiBaseUrlOverride?.trim();

    return configuredValue != null && configuredValue.isNotEmpty;
  }

  factory AppConfig.fromEnvironment() {
    const configuredApiBaseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: '',
    );
    final normalizedApiBaseUrl = configuredApiBaseUrl.trim();

    return AppConfig(
      apiBaseUrlOverride:
          normalizedApiBaseUrl.isEmpty ? null : normalizedApiBaseUrl,
    );
  }
}
