import '../repositories/client_repository.dart';

class DeleteClientUseCase {
  const DeleteClientUseCase(this._clientRepository);

  final ClientRepository _clientRepository;

  Future<void> execute(String clientId) {
    return _clientRepository.deleteClient(clientId);
  }
}
