import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../app/config/app_config.dart';
import '../../core/storage/app_preferences_storage.dart';

class ApiBaseUrlProvider extends ChangeNotifier {
  ApiBaseUrlProvider({
    required AppPreferencesStorage preferencesStorage,
    required AppConfig appConfig,
    http.Client? httpClient,
  })  : _preferencesStorage = preferencesStorage,
        _appConfig = appConfig,
        _httpClient = httpClient ?? http.Client();

  final AppPreferencesStorage _preferencesStorage;
  final AppConfig _appConfig;
  final http.Client _httpClient;

  Future<void>? _bootstrapFuture;
  Future<String>? _ongoingResolution;
  String _currentApiBaseUrl = '';
  bool _hasManualOverride = false;
  bool _isResolving = false;

  String get currentApiBaseUrl => _currentApiBaseUrl;
  bool get hasManualOverride => _hasManualOverride;
  bool get isResolving => _isResolving;

  Future<void> bootstrap() {
    return _bootstrapFuture ??= _bootstrapInternal();
  }

  Future<void> _bootstrapInternal() async {
    final storedApiBaseUrl =
        _normalize(await _preferencesStorage.readApiBaseUrl());

    if (storedApiBaseUrl != null) {
      if (_isLegacyAutomaticUrl(storedApiBaseUrl)) {
        await _preferencesStorage.clearApiBaseUrl();
      } else {
        _hasManualOverride = true;
        _currentApiBaseUrl = storedApiBaseUrl;
        notifyListeners();
        return;
      }
    }

    final cachedAutoDetectedBaseUrl = _normalize(
      await _preferencesStorage.readAutoDetectedApiBaseUrl(),
    );

    if (cachedAutoDetectedBaseUrl != null) {
      _currentApiBaseUrl = cachedAutoDetectedBaseUrl;
      notifyListeners();
      unawaited(
        _resolveAutoDetectedBaseUrl(forceRefresh: true),
      );
      return;
    }

    await _resolveAutoDetectedBaseUrl(forceRefresh: true);
  }

  bool _isLegacyAutomaticUrl(String apiBaseUrl) {
    final normalizedApiBaseUrl = _normalize(apiBaseUrl);

    if (normalizedApiBaseUrl == null) {
      return false;
    }

    return <String>{
      _buildBaseUrl('10.0.2.2'),
      _buildBaseUrl('10.0.3.2'),
      _buildBaseUrl('127.0.0.1'),
      _buildBaseUrl('localhost'),
    }.contains(normalizedApiBaseUrl);
  }

  Future<String> resolveBaseUrl({
    bool forceRefresh = false,
  }) async {
    await bootstrap();

    if (_hasManualOverride) {
      return _currentApiBaseUrl;
    }

    if (!forceRefresh && _currentApiBaseUrl.isNotEmpty) {
      return _currentApiBaseUrl;
    }

    return _resolveAutoDetectedBaseUrl(forceRefresh: true);
  }

  Future<void> setApiBaseUrl(String apiBaseUrl) async {
    final normalizedApiBaseUrl = _normalize(apiBaseUrl);

    if (normalizedApiBaseUrl == null) {
      return;
    }

    if (_isLegacyAutomaticUrl(normalizedApiBaseUrl)) {
      _hasManualOverride = false;
      _currentApiBaseUrl = normalizedApiBaseUrl;
      notifyListeners();
      await _preferencesStorage.clearApiBaseUrl();
      await _preferencesStorage.saveAutoDetectedApiBaseUrl(
        normalizedApiBaseUrl,
      );
      return;
    }

    if (_hasManualOverride && _currentApiBaseUrl == normalizedApiBaseUrl) {
      return;
    }

    _hasManualOverride = true;
    _currentApiBaseUrl = normalizedApiBaseUrl;
    notifyListeners();
    await _preferencesStorage.saveApiBaseUrl(normalizedApiBaseUrl);
  }

  Future<void> resetToDefault() async {
    await _preferencesStorage.clearApiBaseUrl();
    await _preferencesStorage.clearAutoDetectedApiBaseUrl();
    _hasManualOverride = false;
    _currentApiBaseUrl = '';
    notifyListeners();
    await refreshAutoDetectedUrl();
  }

  Future<bool> refreshAutoDetectedUrl() async {
    await bootstrap();

    if (_hasManualOverride) {
      return false;
    }

    final previousApiBaseUrl = _currentApiBaseUrl;
    final resolvedApiBaseUrl = await _resolveAutoDetectedBaseUrl(
      forceRefresh: true,
    );

    return previousApiBaseUrl != resolvedApiBaseUrl;
  }

  Future<String> _resolveAutoDetectedBaseUrl({
    required bool forceRefresh,
  }) {
    if (!forceRefresh && _currentApiBaseUrl.isNotEmpty) {
      return Future.value(_currentApiBaseUrl);
    }

    final ongoingResolution = _ongoingResolution;

    if (ongoingResolution != null) {
      return ongoingResolution;
    }

    final resolution = _discoverAndPersistBestBaseUrl();
    _ongoingResolution = resolution;

    return resolution.whenComplete(() {
      _ongoingResolution = null;
    });
  }

  Future<String> _discoverAndPersistBestBaseUrl() async {
    _setResolving(true);

    try {
      final resolvedApiBaseUrl = await _discoverBestBaseUrl();

      if (_currentApiBaseUrl != resolvedApiBaseUrl) {
        _currentApiBaseUrl = resolvedApiBaseUrl;
        notifyListeners();
      }

      await _preferencesStorage.saveAutoDetectedApiBaseUrl(resolvedApiBaseUrl);

      return resolvedApiBaseUrl;
    } finally {
      _setResolving(false);
    }
  }

  Future<String> _discoverBestBaseUrl() async {
    final cachedAutoDetectedBaseUrl = _normalize(
      await _preferencesStorage.readAutoDetectedApiBaseUrl(),
    );
    final directCandidates = _buildDirectCandidates(
      cachedAutoDetectedBaseUrl: cachedAutoDetectedBaseUrl,
    );
    final directMatch = await _findHealthyBaseUrl(directCandidates);

    if (directMatch != null) {
      return directMatch;
    }

    final lanCandidates = await _buildLanCandidates();
    final lanMatch = await _findHealthyBaseUrl(
      lanCandidates,
      maxConcurrentRequests: 24,
    );

    if (lanMatch != null) {
      return lanMatch;
    }

    if (directCandidates.isNotEmpty) {
      return directCandidates.first;
    }

    return _buildBaseUrl('127.0.0.1');
  }

  List<String> _buildDirectCandidates({
    String? cachedAutoDetectedBaseUrl,
  }) {
    final candidates = LinkedHashSet<String>();

    final configuredApiBaseUrl = _normalize(_appConfig.apiBaseUrlOverride);

    if (configuredApiBaseUrl != null) {
      candidates.add(configuredApiBaseUrl);
    }

    if (cachedAutoDetectedBaseUrl != null) {
      candidates.add(cachedAutoDetectedBaseUrl);
    }

    if (Platform.isAndroid) {
      candidates.add(_buildBaseUrl('10.0.2.2'));
      candidates.add(_buildBaseUrl('10.0.3.2'));
    }

    candidates.add(_buildBaseUrl('127.0.0.1'));
    candidates.add(_buildBaseUrl('localhost'));

    return candidates.toList(growable: false);
  }

  Future<List<String>> _buildLanCandidates() async {
    final addresses = await _readPrivateIpv4Addresses();
    final candidates = LinkedHashSet<String>();

    for (final address in addresses) {
      final octets = _parseIpv4Octets(address.address);

      if (octets == null) {
        continue;
      }

      final subnetPrefix = '${octets[0]}.${octets[1]}.${octets[2]}';

      if (subnetPrefix == '10.0.2' || subnetPrefix == '10.0.3') {
        continue;
      }

      for (final host in _buildPrioritizedHosts(octets[3])) {
        candidates.add(_buildBaseUrl('$subnetPrefix.$host'));
      }
    }

    return candidates.toList(growable: false);
  }

  List<int> _buildPrioritizedHosts(int ownHost) {
    final hosts = LinkedHashSet<int>();

    for (final candidate in <int>[1, 2, 10, 20, 50, 100, 150, 170, 200, 250]) {
      if (candidate != ownHost) {
        hosts.add(candidate);
      }
    }

    for (var offset = 1; offset <= 12; offset++) {
      final lower = ownHost - offset;
      final upper = ownHost + offset;

      if (lower > 0) {
        hosts.add(lower);
      }

      if (upper < 255) {
        hosts.add(upper);
      }
    }

    for (var host = 1; host <= 254; host++) {
      if (host != ownHost) {
        hosts.add(host);
      }
    }

    return hosts.toList(growable: false);
  }

  Future<List<InternetAddress>> _readPrivateIpv4Addresses() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
      );
      final addresses = <InternetAddress>[];

      for (final interface in interfaces) {
        for (final address in interface.addresses) {
          if (_isPrivateIpv4(address.address)) {
            addresses.add(address);
          }
        }
      }

      return addresses;
    } catch (_) {
      return const <InternetAddress>[];
    }
  }

  Future<String?> _findHealthyBaseUrl(
    Iterable<String> candidates, {
    int maxConcurrentRequests = 1,
  }) async {
    final pendingCandidates = Queue<String>.from(
      candidates.where((candidate) => candidate.trim().isNotEmpty),
    );

    while (pendingCandidates.isNotEmpty) {
      final batch = <Future<String?>>[];

      for (var index = 0;
          index < maxConcurrentRequests && pendingCandidates.isNotEmpty;
          index++) {
        batch.add(_probeBaseUrl(pendingCandidates.removeFirst()));
      }

      final results = await Future.wait(batch);

      for (final result in results) {
        if (result != null) {
          return result;
        }
      }
    }

    return null;
  }

  Future<String?> _probeBaseUrl(String baseUrl) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/health'),
        headers: const {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(milliseconds: 900));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return baseUrl;
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  String _buildBaseUrl(String host) {
    return 'http://$host:${AppConfig.defaultApiPort}${AppConfig.defaultApiPath}';
  }

  bool _isPrivateIpv4(String value) {
    final octets = _parseIpv4Octets(value);

    if (octets == null) {
      return false;
    }

    final first = octets[0];
    final second = octets[1];

    if (first == 10) {
      return true;
    }

    if (first == 172 && second >= 16 && second <= 31) {
      return true;
    }

    if (first == 192 && second == 168) {
      return true;
    }

    return false;
  }

  List<int>? _parseIpv4Octets(String value) {
    final segments = value.split('.');

    if (segments.length != 4) {
      return null;
    }

    final octets = <int>[];

    for (final segment in segments) {
      final parsedValue = int.tryParse(segment);

      if (parsedValue == null || parsedValue < 0 || parsedValue > 255) {
        return null;
      }

      octets.add(parsedValue);
    }

    return octets;
  }

  void _setResolving(bool value) {
    if (_isResolving == value) {
      return;
    }

    _isResolving = value;
    notifyListeners();
  }

  String? _normalize(String? value) {
    final normalizedValue = value?.trim();

    if (normalizedValue == null || normalizedValue.isEmpty) {
      return null;
    }

    final parsedUri = Uri.tryParse(normalizedValue);

    if (parsedUri == null || !parsedUri.hasScheme || !parsedUri.hasAuthority) {
      return normalizedValue.replaceFirst(RegExp(r'/+$'), '');
    }

    final normalizedPath = parsedUri.path == '/'
        ? ''
        : parsedUri.path.replaceFirst(RegExp(r'/+$'), '');
    final normalizedPort = parsedUri.hasPort ? ':${parsedUri.port}' : '';

    return '${parsedUri.scheme.toLowerCase()}://${parsedUri.host.toLowerCase()}$normalizedPort$normalizedPath';
  }
}
