import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../errors/api_exception.dart';
import '../storage/app_preferences_storage.dart';
import '../storage/token_storage.dart';

class ApiClient {
  ApiClient({
    required String baseUrl,
    required AppPreferencesStorage preferencesStorage,
    required TokenStorage tokenStorage,
    http.Client? httpClient,
  })  : _baseUrl = baseUrl,
        _preferencesStorage = preferencesStorage,
        _tokenStorage = tokenStorage,
        _httpClient = httpClient ?? http.Client();

  final String _baseUrl;
  final AppPreferencesStorage _preferencesStorage;
  final TokenStorage _tokenStorage;
  final http.Client _httpClient;

  Future<dynamic> get(
    String path, {
    Map<String, String>? queryParameters,
    bool authenticated = true,
  }) async {
    final response = await _runRequest(
      () async => _httpClient
          .get(
            await _buildUri(path, queryParameters: queryParameters),
            headers: await _buildHeaders(authenticated: authenticated),
          )
          .timeout(ApiConstants.requestTimeout),
    );

    return _parseResponse(response);
  }

  Future<List<int>> getBytes(
    String path, {
    Map<String, String>? queryParameters,
    bool authenticated = true,
  }) async {
    final response = await _runRequest(
      () async => _httpClient
          .get(
            await _buildUri(path, queryParameters: queryParameters),
            headers: await _buildHeaders(authenticated: authenticated),
          )
          .timeout(ApiConstants.requestTimeout),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.bodyBytes;
    }

    final body = response.body.trim();
    final decodedBody = body.isEmpty ? null : jsonDecode(body);

    throw ApiException(
      statusCode: response.statusCode,
      message: _extractErrorMessage(decodedBody, response.statusCode),
    );
  }

  Future<dynamic> postJson(
    String path, {
    required Map<String, dynamic> body,
    bool authenticated = true,
  }) async {
    final response = await _runRequest(
      () async => _httpClient
          .post(
            await _buildUri(path),
            headers: await _buildHeaders(
              authenticated: authenticated,
              includeJsonContentType: true,
            ),
            body: jsonEncode(body),
          )
          .timeout(ApiConstants.requestTimeout),
    );

    return _parseResponse(response);
  }

  Future<dynamic> patchJson(
    String path, {
    required Map<String, dynamic> body,
    bool authenticated = true,
  }) async {
    final response = await _runRequest(
      () async => _httpClient
          .patch(
            await _buildUri(path),
            headers: await _buildHeaders(
              authenticated: authenticated,
              includeJsonContentType: true,
            ),
            body: jsonEncode(body),
          )
          .timeout(ApiConstants.requestTimeout),
    );

    return _parseResponse(response);
  }

  Future<dynamic> sendMultipart(
    String path, {
    required String fileFieldName,
    required List<int> fileBytes,
    required String fileName,
    Map<String, String>? fields,
    bool authenticated = true,
  }) async {
    final request = http.MultipartRequest('POST', await _buildUri(path));

    request.headers.addAll(
      await _buildHeaders(
        authenticated: authenticated,
        includeJsonContentType: false,
      ),
    );
    request.fields.addAll(fields ?? const {});
    request.files.add(
      http.MultipartFile.fromBytes(
        fileFieldName,
        fileBytes,
        filename: fileName,
      ),
    );

    final streamedResponse = await _runRequest(
      () => request.send().timeout(ApiConstants.requestTimeout),
    );
    final response = await http.Response.fromStream(streamedResponse);

    return _parseResponse(response);
  }

  Future<Uri> _buildUri(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('${await _resolveBaseUrl()}$normalizedPath');

    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }

    return uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        ...queryParameters,
      },
    );
  }

  Future<T> _runRequest<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on TimeoutException {
      throw ApiException(
        statusCode: 0,
        message: _buildConnectivityErrorMessage(),
      );
    } on SocketException {
      throw ApiException(
        statusCode: 0,
        message: _buildConnectivityErrorMessage(),
      );
    } on http.ClientException {
      throw ApiException(
        statusCode: 0,
        message: _buildConnectivityErrorMessage(),
      );
    }
  }

  Future<String> _resolveBaseUrl() async {
    final storedApiBaseUrl = await _preferencesStorage.readApiBaseUrl();
    final normalizedApiBaseUrl = storedApiBaseUrl?.trim();

    if (normalizedApiBaseUrl == null || normalizedApiBaseUrl.isEmpty) {
      return _baseUrl;
    }

    return normalizedApiBaseUrl;
  }

  String _buildConnectivityErrorMessage() {
    return 'Could not connect to the API. If you are using a physical phone, open Settings and replace 10.0.2.2 with your computer IP.';
  }

  Future<Map<String, String>> _buildHeaders({
    required bool authenticated,
    bool includeJsonContentType = false,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
    };

    if (includeJsonContentType) {
      headers['Content-Type'] = 'application/json';
    }

    if (authenticated) {
      final accessToken = await _tokenStorage.readAccessToken();

      if (accessToken != null && accessToken.isNotEmpty) {
        headers['Authorization'] =
            '${ApiConstants.authorizationScheme} $accessToken';
      }
    }

    return headers;
  }

  dynamic _parseResponse(http.Response response) {
    final body = response.body.trim();
    final decodedBody = body.isEmpty ? null : jsonDecode(body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decodedBody;
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: _extractErrorMessage(decodedBody, response.statusCode),
    );
  }

  String _extractErrorMessage(dynamic decodedBody, int statusCode) {
    if (decodedBody is Map<String, dynamic>) {
      final message = decodedBody['message'];

      if (message is String && message.trim().isNotEmpty) {
        return message;
      }

      if (message is List) {
        final messages = message.whereType<String>().toList();

        if (messages.isNotEmpty) {
          return messages.join('\n');
        }
      }
    }

    return 'Request failed with status code $statusCode.';
  }
}
