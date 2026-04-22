class AppConfig {
  const AppConfig({
    required this.apiBaseUrlOverride,
  });

  static const String appName = 'Prime Lawyer';
  static const int defaultApiPort = 3000;
  static const String defaultApiPath = '/api/v1';

  static const String defaultApiBaseUrlEmulator =
      'http://10.0.2.2:$defaultApiPort$defaultApiPath';

  final String? apiBaseUrlOverride;

  String get apiBaseUrl {
    final configuredValue = apiBaseUrlOverride?.trim();

    if (configuredValue != null && configuredValue.isNotEmpty) {
      return configuredValue;
    }

    return defaultApiBaseUrlEmulator;
  }

  static bool isLocalNetworkApiBaseUrl(String value) {
    if (value.contains('10.0.2.2') || value.contains('10.0.3.2')) {
      return false;
    }

    if (value.contains('localhost') || value.contains('127.0.0.1')) {
      return false;
    }

    final parsedUri = Uri.tryParse(value);

    if (parsedUri == null || !parsedUri.hasScheme || !parsedUri.hasAuthority) {
      return false;
    }

    final host = parsedUri.host.toLowerCase();

    if (host == 'localhost' || host == '127.0.0.1') {
      return false;
    }

    if (!host.contains('.')) {
      return false; // Very basic check, typically IP or local domain has dots, but actually just rejecting localhost/127/10.0.x is enough.
    }

    return true;
  }

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
