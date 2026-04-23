import '../../../../core/network/api_client.dart';
import '../models/client_model.dart';

class ClientsRemoteDataSource {
  const ClientsRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ClientModel>> getClients({
    String? term,
  }) async {
    final response = await _apiClient.get(
      '/clients',
      queryParameters: {
        if (term != null && term.trim().isNotEmpty) 'term': term.trim(),
      },
    );

    final items = (response as Map<String, dynamic>)['items'] as List<dynamic>;

    return items
        .map((item) => ClientModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ClientModel> createClient({
    required String firstName,
    required String lastName,
    required String documentNumber,
    String? phone,
    String? email,
    String? address,
    String? notes,
  }) async {
    final response = await _apiClient.postJson(
      '/clients',
      body: {
        'firstName': firstName,
        'lastName': lastName,
        'documentNumber': documentNumber,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (email != null && email.isNotEmpty) 'email': email,
        if (address != null && address.isNotEmpty) 'address': address,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );

    return ClientModel.fromJson(response as Map<String, dynamic>);
  }

  Future<ClientModel> updateClient({
    required String clientId,
    required String firstName,
    required String lastName,
    required String documentNumber,
    String? phone,
    String? email,
    String? address,
    String? notes,
  }) async {
    final response = await _apiClient.patchJson(
      '/clients/$clientId',
      body: {
        'firstName': firstName,
        'lastName': lastName,
        'documentNumber': documentNumber,
        'phone': phone,
        'email': email,
        'address': address,
        'notes': notes,
      },
    );

    return ClientModel.fromJson(response as Map<String, dynamic>);
  }

  Future<void> deleteClient(String clientId) async {
    await _apiClient.delete('/clients/$clientId');
  }
}
