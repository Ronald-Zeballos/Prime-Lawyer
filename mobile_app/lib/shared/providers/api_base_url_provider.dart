import 'package:flutter/foundation.dart';

import '../../app/config/app_config.dart';
import '../../core/storage/app_preferences_storage.dart';

class ApiBaseUrlProvider extends ChangeNotifier {
  ApiBaseUrlProvider({
    required AppPreferencesStorage preferencesStorage,
    required AppConfig appConfig,
  })  : _preferencesStorage = preferencesStorage,
        _defaultApiBaseUrl = appConfig.apiBaseUrl,
        _currentApiBaseUrl = appConfig.apiBaseUrl;

  final AppPreferencesStorage _preferencesStorage;
  final String _defaultApiBaseUrl;

  String _currentApiBaseUrl;

  String get currentApiBaseUrl => _currentApiBaseUrl;
  String get defaultApiBaseUrl => _defaultApiBaseUrl;

  Future<void> bootstrap() async {
    final storedApiBaseUrl = await _preferencesStorage.readApiBaseUrl();
    final normalizedApiBaseUrl = _normalize(storedApiBaseUrl);

    _currentApiBaseUrl = normalizedApiBaseUrl ?? _defaultApiBaseUrl;
    notifyListeners();
  }

  Future<void> setApiBaseUrl(String apiBaseUrl) async {
    final normalizedApiBaseUrl = _normalize(apiBaseUrl);

    if (normalizedApiBaseUrl == null) {
      return;
    }

    if (_currentApiBaseUrl == normalizedApiBaseUrl) {
      return;
    }

    _currentApiBaseUrl = normalizedApiBaseUrl;
    notifyListeners();
    await _preferencesStorage.saveApiBaseUrl(normalizedApiBaseUrl);
  }

  Future<void> resetToDefault() async {
    if (_currentApiBaseUrl == _defaultApiBaseUrl) {
      return;
    }

    _currentApiBaseUrl = _defaultApiBaseUrl;
    notifyListeners();
    await _preferencesStorage.clearApiBaseUrl();
  }

  String? _normalize(String? value) {
    final normalizedValue = value?.trim();

    if (normalizedValue == null || normalizedValue.isEmpty) {
      return null;
    }

    return normalizedValue;
  }
}
