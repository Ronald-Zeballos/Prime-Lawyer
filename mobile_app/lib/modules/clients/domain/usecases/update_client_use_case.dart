import '../entities/client.dart';
import '../repositories/client_repository.dart';

class UpdateClientUseCase {
  const UpdateClientUseCase(this._clientRepository);

  final ClientRepository _clientRepository;

  Future<Client> execute(UpdateClientInput input) {
    return _clientRepository.updateClient(input);
  }
}
