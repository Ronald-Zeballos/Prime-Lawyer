import { Client as PrismaClientModel } from '@prisma/client';
import { ClientEntity } from '../../../domain/entities/client.entity';

export class ClientPrismaMapper {
  static toDomain(client: PrismaClientModel): ClientEntity {
    return ClientEntity.create({
      id: client.id,
      firstName: client.firstName,
      lastName: client.lastName,
      documentNumber: client.documentNumber,
      phone: client.phone,
      email: client.email,
      address: client.address,
      notes: client.notes,
      createdAt: client.createdAt,
      updatedAt: client.updatedAt,
    });
  }
}
