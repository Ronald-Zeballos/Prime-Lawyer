import '../entities/client.dart';
import '../repositories/client_repository.dart';

class CreateClientUseCase {
  const CreateClientUseCase(this._clientRepository);

  final ClientRepository _clientRepository;

  Future<Client> execute(CreateClientInput input) {
    return _clientRepository.createClient(input);
  }
}
