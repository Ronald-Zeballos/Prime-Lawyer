import '../network/api_client.dart';

class ApiHealthService {
  const ApiHealthService(this._apiClient);

  final ApiClient _apiClient;

  Future<bool> ping() async {
    final response = await _apiClient.get(
      '/health',
      authenticated: false,
    );

    if (response is Map<String, dynamic>) {
      return (response['status'] as String?) == 'ok';
    }

    return false;
  }
}
