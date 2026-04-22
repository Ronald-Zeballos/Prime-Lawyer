import 'package:flutter_test/flutter_test.dart';
import 'package:prime_lawyer_mobile_app/app/config/app_config.dart';
import 'package:prime_lawyer_mobile_app/core/services/device_runtime_service.dart';
import 'package:prime_lawyer_mobile_app/core/storage/app_preferences_storage.dart';
import 'package:prime_lawyer_mobile_app/shared/providers/api_base_url_provider.dart';

class _FakeAppPreferencesStorage implements AppPreferencesStorage {
  String? languageCode;
  String? apiBaseUrl;
  String? lastLocalNetworkApiBaseUrl;

  @override
  Future<void> clearApiBaseUrl() async {
    apiBaseUrl = null;
  }

  @override
  Future<void> clearLastLocalNetworkApiBaseUrl() async {
    lastLocalNetworkApiBaseUrl = null;
  }

  @override
  Future<String?> readApiBaseUrl() async => apiBaseUrl;

  @override
  Future<String?> readLanguageCode() async => languageCode;

  @override
  Future<String?> readLastLocalNetworkApiBaseUrl() async =>
      lastLocalNetworkApiBaseUrl;

  @override
  Future<void> saveApiBaseUrl(String apiBaseUrl) async {
    this.apiBaseUrl = apiBaseUrl;
  }

  @override
  Future<void> saveLanguageCode(String languageCode) async {
    this.languageCode = languageCode;
  }

  @override
  Future<void> saveLastLocalNetworkApiBaseUrl(String apiBaseUrl) async {
    lastLocalNetworkApiBaseUrl = apiBaseUrl;
  }
}

class _FakeDeviceRuntimeService implements DeviceRuntimeService {
  _FakeDeviceRuntimeService(this.kind);

  DeviceRuntimeKind kind;

  @override
  Future<DeviceRuntimeKind> getCurrentDeviceKind() async => kind;
}

void main() {
  const emulatorApiBaseUrl = AppConfig.defaultApiBaseUrlEmulator;
  const localNetworkApiBaseUrl = 'http://192.168.0.10:3000/api/v1';
  const anotherLocalNetworkApiBaseUrl = 'http://192.168.0.15:3000/api/v1';

  group('ApiBaseUrlProvider', () {
    late _FakeAppPreferencesStorage preferencesStorage;
    late _FakeDeviceRuntimeService deviceRuntimeService;

    ApiBaseUrlProvider buildProvider({
      String defaultApiBaseUrl = emulatorApiBaseUrl,
    }) {
      return ApiBaseUrlProvider(
        preferencesStorage: preferencesStorage,
        appConfig: AppConfig(apiBaseUrlOverride: defaultApiBaseUrl),
        deviceRuntimeService: deviceRuntimeService,
      );
    }

    setUp(() {
      preferencesStorage = _FakeAppPreferencesStorage();
      deviceRuntimeService = _FakeDeviceRuntimeService(
        DeviceRuntimeKind.virtual,
      );
    });

    test('setApiBaseUrl remembers a local network URL', () async {
      final provider = buildProvider();
      await provider.bootstrap();

      final result = await provider.setApiBaseUrl(localNetworkApiBaseUrl);

      expect(result.status, ApiBaseUrlActionStatus.applied);
      expect(provider.currentApiBaseUrl, localNetworkApiBaseUrl);
      expect(
        provider.lastLocalNetworkApiBaseUrl,
        localNetworkApiBaseUrl,
      );
      expect(preferencesStorage.apiBaseUrl, localNetworkApiBaseUrl);
      expect(
        preferencesStorage.lastLocalNetworkApiBaseUrl,
        localNetworkApiBaseUrl,
      );
    });

    test('switching to emulator keeps the remembered local network URL',
        () async {
      final provider = buildProvider();
      await provider.bootstrap();
      await provider.setApiBaseUrl(localNetworkApiBaseUrl);

      final result = await provider.useEmulatorApiBaseUrl();

      expect(result.status, ApiBaseUrlActionStatus.applied);
      expect(provider.currentApiBaseUrl, emulatorApiBaseUrl);
      expect(
        provider.lastLocalNetworkApiBaseUrl,
        localNetworkApiBaseUrl,
      );
      expect(
        preferencesStorage.lastLocalNetworkApiBaseUrl,
        localNetworkApiBaseUrl,
      );
    });

    test(
        'resetToDefault on a physical device prefers the remembered local network URL',
        () async {
      preferencesStorage.apiBaseUrl = emulatorApiBaseUrl;
      preferencesStorage.lastLocalNetworkApiBaseUrl = localNetworkApiBaseUrl;
      deviceRuntimeService.kind = DeviceRuntimeKind.physical;
      final provider = buildProvider();
      await provider.bootstrap();

      final result = await provider.resetToDefault();

      expect(result.status, ApiBaseUrlActionStatus.applied);
      expect(result.apiBaseUrl, localNetworkApiBaseUrl);
      expect(provider.currentApiBaseUrl, localNetworkApiBaseUrl);
      expect(preferencesStorage.apiBaseUrl, localNetworkApiBaseUrl);
    });

    test('resetToDefault on an emulator uses the emulator URL', () async {
      preferencesStorage.apiBaseUrl = anotherLocalNetworkApiBaseUrl;
      preferencesStorage.lastLocalNetworkApiBaseUrl =
          anotherLocalNetworkApiBaseUrl;
      deviceRuntimeService.kind = DeviceRuntimeKind.virtual;
      final provider = buildProvider(
        defaultApiBaseUrl: localNetworkApiBaseUrl,
      );
      await provider.bootstrap();

      final result = await provider.resetToDefault();

      expect(result.status, ApiBaseUrlActionStatus.applied);
      expect(result.apiBaseUrl, emulatorApiBaseUrl);
      expect(provider.currentApiBaseUrl, emulatorApiBaseUrl);
      expect(
        provider.lastLocalNetworkApiBaseUrl,
        anotherLocalNetworkApiBaseUrl,
      );
    });

    test('useLocalNetworkApiBaseUrl fails when no LAN URL is known', () async {
      final provider = buildProvider();
      await provider.bootstrap();

      final result = await provider.useLocalNetworkApiBaseUrl();

      expect(result.status, ApiBaseUrlActionStatus.unavailable);
      expect(
        result.unavailableReason,
        ApiBaseUrlActionUnavailableReason.missingLocalNetworkApiBaseUrl,
      );
    });

    test(
        'bootstrap migrates the current LAN URL into remembered local network URL',
        () async {
      preferencesStorage.apiBaseUrl = localNetworkApiBaseUrl;
      final provider = buildProvider();

      await provider.bootstrap();

      expect(
        provider.lastLocalNetworkApiBaseUrl,
        localNetworkApiBaseUrl,
      );
      expect(
        preferencesStorage.lastLocalNetworkApiBaseUrl,
        localNetworkApiBaseUrl,
      );
    });
  });
}
