import '../../domain/entities/client.dart';
import '../../domain/repositories/client_repository.dart';
import '../datasources/clients_remote_data_source.dart';
import '../mappers/client_mapper.dart';

class ClientRepositoryImpl implements ClientRepository {
  const ClientRepositoryImpl(this._remoteDataSource);

  final ClientsRemoteDataSource _remoteDataSource;

  @override
  Future<Client> createClient(CreateClientInput input) async {
    final clientModel = await _remoteDataSource.createClient(
      firstName: input.firstName,
      lastName: input.lastName,
      documentNumber: input.documentNumber,
      phone: input.phone,
      email: input.email,
      address: input.address,
      notes: input.notes,
    );

    return ClientMapper.toDomain(clientModel);
  }

  @override
  Future<List<Client>> getClients({
    String? term,
  }) async {
    final clientModels = await _remoteDataSource.getClients(term: term);

    return clientModels.map(ClientMapper.toDomain).toList();
  }
}
