import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../errors/api_exception.dart';
import '../services/session_service.dart';
import '../../shared/providers/api_base_url_provider.dart';

class ApiClient {
  ApiClient({
    required ApiBaseUrlProvider apiBaseUrlProvider,
    required SessionService sessionService,
    http.Client? httpClient,
  })  : _apiBaseUrlProvider = apiBaseUrlProvider,
        _sessionService = sessionService,
        _httpClient = httpClient ?? http.Client();

  final ApiBaseUrlProvider _apiBaseUrlProvider;
  final SessionService _sessionService;
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

    return _parseResponse(
      response,
      invalidateSessionOnUnauthorized: authenticated,
    );
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

    await _invalidateSessionIfUnauthorized(
      statusCode: response.statusCode,
      invalidateSessionOnUnauthorized: authenticated,
    );

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

    return _parseResponse(
      response,
      invalidateSessionOnUnauthorized: authenticated,
    );
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

    return _parseResponse(
      response,
      invalidateSessionOnUnauthorized: authenticated,
    );
  }

  Future<dynamic> delete(
    String path, {
    Map<String, String>? queryParameters,
    bool authenticated = true,
  }) async {
    final response = await _runRequest(
      () async => _httpClient
          .delete(
            await _buildUri(path, queryParameters: queryParameters),
            headers: await _buildHeaders(authenticated: authenticated),
          )
          .timeout(ApiConstants.requestTimeout),
    );

    return _parseResponse(
      response,
      invalidateSessionOnUnauthorized: authenticated,
    );
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

    return _parseResponse(
      response,
      invalidateSessionOnUnauthorized: authenticated,
    );
  }

  Future<Uri> _buildUri(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final uri =
        Uri.parse('${_apiBaseUrlProvider.currentApiBaseUrl}$normalizedPath');

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

  Future<T> _runRequest<T>(
    Future<T> Function() request, {
    bool allowRetry = true,
  }) async {
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

  String _buildConnectivityErrorMessage() {
    final currentApiBaseUrl = _apiBaseUrlProvider.currentApiBaseUrl.trim();

    if (currentApiBaseUrl.isEmpty) {
      return 'Could not connect to the API. Open Settings and review the manual URL.';
    }

    return 'Could not connect to the API at $currentApiBaseUrl. Open Settings and review the manual URL.';
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
      final accessToken = await _sessionService.restoreAccessToken();

      if (accessToken != null && accessToken.isNotEmpty) {
        headers['Authorization'] =
            '${ApiConstants.authorizationScheme} $accessToken';
      }
    }

    return headers;
  }

  Future<dynamic> _parseResponse(
    http.Response response, {
    required bool invalidateSessionOnUnauthorized,
  }) async {
    final body = response.body.trim();
    final decodedBody = body.isEmpty ? null : jsonDecode(body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decodedBody;
    }

    await _invalidateSessionIfUnauthorized(
      statusCode: response.statusCode,
      invalidateSessionOnUnauthorized: invalidateSessionOnUnauthorized,
    );

    throw ApiException(
      statusCode: response.statusCode,
      message: _extractErrorMessage(decodedBody, response.statusCode),
    );
  }

  Future<void> _invalidateSessionIfUnauthorized({
    required int statusCode,
    required bool invalidateSessionOnUnauthorized,
  }) async {
    if (!invalidateSessionOnUnauthorized || statusCode != 401) {
      return;
    }

    await _sessionService.invalidateSession();
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
