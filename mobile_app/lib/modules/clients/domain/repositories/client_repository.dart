import '../entities/client.dart';

class CreateClientInput {
  const CreateClientInput({
    required this.firstName,
    required this.lastName,
    required this.documentNumber,
    this.phone,
    this.email,
    this.address,
    this.notes,
  });

  final String firstName;
  final String lastName;
  final String documentNumber;
  final String? phone;
  final String? email;
  final String? address;
  final String? notes;
}

class UpdateClientInput {
  const UpdateClientInput({
    required this.clientId,
    required this.firstName,
    required this.lastName,
    required this.documentNumber,
    this.phone,
    this.email,
    this.address,
    this.notes,
  });

  final String clientId;
  final String firstName;
  final String lastName;
  final String documentNumber;
  final String? phone;
  final String? email;
  final String? address;
  final String? notes;
}

abstract class ClientRepository {
  Future<List<Client>> getClients({
    String? term,
  });

  Future<Client> createClient(CreateClientInput input);
  Future<Client> updateClient(UpdateClientInput input);
  Future<void> deleteClient(String clientId);
}
