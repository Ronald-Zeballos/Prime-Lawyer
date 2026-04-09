import '../entities/client.dart';
import '../repositories/client_repository.dart';

class GetClientsUseCase {
  const GetClientsUseCase(this._clientRepository);

  final ClientRepository _clientRepository;

  Future<List<Client>> execute({
    String? term,
  }) {
    return _clientRepository.getClients(term: term);
  }
}
