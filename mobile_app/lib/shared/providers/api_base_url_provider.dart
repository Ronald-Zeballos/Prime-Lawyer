import 'package:flutter/foundation.dart';

import '../../app/config/app_config.dart';
import '../../core/services/device_runtime_service.dart';
import '../../core/storage/app_preferences_storage.dart';

enum ApiBaseUrlActionStatus {
  applied,
  alreadyActive,
  unavailable,
}

enum ApiBaseUrlActionUnavailableReason {
  missingLocalNetworkApiBaseUrl,
}

class ApiBaseUrlActionResult {
  const ApiBaseUrlActionResult({
    required this.status,
    this.apiBaseUrl,
    this.unavailableReason,
  });

  final ApiBaseUrlActionStatus status;
  final String? apiBaseUrl;
  final ApiBaseUrlActionUnavailableReason? unavailableReason;

  bool get isSuccessful => status != ApiBaseUrlActionStatus.unavailable;
}

class ApiBaseUrlProvider extends ChangeNotifier {
  ApiBaseUrlProvider({
    required AppPreferencesStorage preferencesStorage,
    required AppConfig appConfig,
    required DeviceRuntimeService deviceRuntimeService,
  })  : _preferencesStorage = preferencesStorage,
        _deviceRuntimeService = deviceRuntimeService,
        _defaultApiBaseUrl = appConfig.apiBaseUrl,
        _currentApiBaseUrl = appConfig.apiBaseUrl;

  final AppPreferencesStorage _preferencesStorage;
  final DeviceRuntimeService _deviceRuntimeService;
  final String _defaultApiBaseUrl;

  String _currentApiBaseUrl;
  String? _lastLocalNetworkApiBaseUrl;

  String get currentApiBaseUrl => _currentApiBaseUrl;
  String get defaultApiBaseUrl => _defaultApiBaseUrl;
  String? get lastLocalNetworkApiBaseUrl => _lastLocalNetworkApiBaseUrl;

  Future<void> bootstrap() async {
    final storedApiBaseUrl =
        _normalize(await _preferencesStorage.readApiBaseUrl());
    final storedLastLocalNetworkApiBaseUrl = _normalizeLocalNetworkApiBaseUrl(
      await _preferencesStorage.readLastLocalNetworkApiBaseUrl(),
    );
    final inferredLastLocalNetworkApiBaseUrl =
        storedLastLocalNetworkApiBaseUrl ??
            _normalizeLocalNetworkApiBaseUrl(storedApiBaseUrl) ??
            _normalizeLocalNetworkApiBaseUrl(_defaultApiBaseUrl);

    _currentApiBaseUrl = storedApiBaseUrl ?? _defaultApiBaseUrl;
    _lastLocalNetworkApiBaseUrl = inferredLastLocalNetworkApiBaseUrl;

    if (storedLastLocalNetworkApiBaseUrl == null &&
        inferredLastLocalNetworkApiBaseUrl != null) {
      await _preferencesStorage.saveLastLocalNetworkApiBaseUrl(
        inferredLastLocalNetworkApiBaseUrl,
      );
    }

    notifyListeners();
  }

  Future<ApiBaseUrlActionResult> setApiBaseUrl(String apiBaseUrl) {
    return _applyApiBaseUrl(apiBaseUrl);
  }

  Future<ApiBaseUrlActionResult> resetToDefault() async {
    final deviceRuntimeKind =
        await _deviceRuntimeService.getCurrentDeviceKind();

    switch (deviceRuntimeKind) {
      case DeviceRuntimeKind.physical:
        final localNetworkApiBaseUrl =
            _resolvePreferredLocalNetworkApiBaseUrl();

        if (localNetworkApiBaseUrl == null) {
          return const ApiBaseUrlActionResult(
            status: ApiBaseUrlActionStatus.unavailable,
            unavailableReason:
                ApiBaseUrlActionUnavailableReason.missingLocalNetworkApiBaseUrl,
          );
        }

        return _applyApiBaseUrl(localNetworkApiBaseUrl);
      case DeviceRuntimeKind.virtual:
        return _applyApiBaseUrl(AppConfig.defaultApiBaseUrlEmulator);
      case DeviceRuntimeKind.unsupported:
        return _applyApiBaseUrl(_defaultApiBaseUrl);
    }
  }

  Future<ApiBaseUrlActionResult> useLocalNetworkApiBaseUrl() async {
    final localNetworkApiBaseUrl = _resolvePreferredLocalNetworkApiBaseUrl();

    if (localNetworkApiBaseUrl == null) {
      return const ApiBaseUrlActionResult(
        status: ApiBaseUrlActionStatus.unavailable,
        unavailableReason:
            ApiBaseUrlActionUnavailableReason.missingLocalNetworkApiBaseUrl,
      );
    }

    return _applyApiBaseUrl(localNetworkApiBaseUrl);
  }

  Future<ApiBaseUrlActionResult> useEmulatorApiBaseUrl() {
    return _applyApiBaseUrl(AppConfig.defaultApiBaseUrlEmulator);
  }

  Future<ApiBaseUrlActionResult> _applyApiBaseUrl(String apiBaseUrl) async {
    final normalizedApiBaseUrl = _normalize(apiBaseUrl);

    if (normalizedApiBaseUrl == null) {
      return const ApiBaseUrlActionResult(
        status: ApiBaseUrlActionStatus.unavailable,
      );
    }

    final normalizedLocalNetworkApiBaseUrl =
        _normalizeLocalNetworkApiBaseUrl(normalizedApiBaseUrl);

    if (normalizedLocalNetworkApiBaseUrl != null &&
        normalizedLocalNetworkApiBaseUrl != _lastLocalNetworkApiBaseUrl) {
      _lastLocalNetworkApiBaseUrl = normalizedLocalNetworkApiBaseUrl;
      await _preferencesStorage.saveLastLocalNetworkApiBaseUrl(
        normalizedLocalNetworkApiBaseUrl,
      );
    }

    final alreadyActive = normalizedApiBaseUrl == _currentApiBaseUrl;

    await _preferencesStorage.saveApiBaseUrl(normalizedApiBaseUrl);

    if (!alreadyActive) {
      _currentApiBaseUrl = normalizedApiBaseUrl;
      notifyListeners();
    }

    return ApiBaseUrlActionResult(
      status: alreadyActive
          ? ApiBaseUrlActionStatus.alreadyActive
          : ApiBaseUrlActionStatus.applied,
      apiBaseUrl: normalizedApiBaseUrl,
    );
  }

  String? _resolvePreferredLocalNetworkApiBaseUrl() {
    final candidates = <String?>[
      _lastLocalNetworkApiBaseUrl,
      _currentApiBaseUrl,
      _defaultApiBaseUrl,
    ];

    for (final candidate in candidates) {
      final normalizedCandidate = _normalizeLocalNetworkApiBaseUrl(candidate);

      if (normalizedCandidate != null) {
        return normalizedCandidate;
      }
    }

    return null;
  }

  String? _normalizeLocalNetworkApiBaseUrl(String? value) {
    final normalizedValue = _normalize(value);

    if (normalizedValue == null) {
      return null;
    }

    if (!AppConfig.isLocalNetworkApiBaseUrl(normalizedValue)) {
      return null;
    }

    return normalizedValue;
  }

  String? _normalize(String? value) {
    final normalizedValue = value?.trim();

    if (normalizedValue == null || normalizedValue.isEmpty) {
      return null;
    }

    return normalizedValue;
  }
}
