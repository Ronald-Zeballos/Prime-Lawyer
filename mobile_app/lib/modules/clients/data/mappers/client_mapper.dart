import '../../domain/entities/client.dart';
import '../models/client_model.dart';

class ClientMapper {
  const ClientMapper._();

  static Client toDomain(ClientModel model) {
    return Client(
      id: model.id,
      firstName: model.firstName,
      lastName: model.lastName,
      documentNumber: model.documentNumber,
      phone: model.phone,
      email: model.email,
      address: model.address,
      notes: model.notes,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }
}
