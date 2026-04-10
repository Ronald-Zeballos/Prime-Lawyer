import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../../../shared/infrastructure/prisma/prisma.service';
import { ClientEntity } from '../../../domain/entities/client.entity';
import { ClientRepository } from '../../../domain/repositories/client.repository';
import { ClientId } from '../../../domain/value-objects/client-id.vo';
import { DocumentNumber } from '../../../domain/value-objects/document-number.vo';
import { ClientPrismaMapper } from '../mappers/client-prisma.mapper';

@Injectable()
export class PrismaClientRepository implements ClientRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findById(id: ClientId): Promise<ClientEntity | null> {
    const client = await this.prisma.client.findUnique({
      where: { id: id.value },
    });

    return client ? ClientPrismaMapper.toDomain(client) : null;
  }

  async findByDocumentNumber(
    documentNumber: DocumentNumber,
  ): Promise<ClientEntity | null> {
    const client = await this.prisma.client.findUnique({
      where: { documentNumber: documentNumber.value },
    });

    return client ? ClientPrismaMapper.toDomain(client) : null;
  }

  async search(term?: string): Promise<ClientEntity[]> {
    const normalizedTerm = term?.trim();
    const where = normalizedTerm
      ? {
          OR: [
            { firstName: { contains: normalizedTerm, mode: 'insensitive' as const } },
            { lastName: { contains: normalizedTerm, mode: 'insensitive' as const } },
            {
              documentNumber: {
                contains: normalizedTerm,
                mode: 'insensitive' as const,
              },
            },
            { email: { contains: normalizedTerm, mode: 'insensitive' as const } },
          ],
        }
      : undefined;

    const clients = await this.prisma.client.findMany({
      where,
      orderBy: [{ createdAt: 'desc' }],
    });

    return clients.map((client) => ClientPrismaMapper.toDomain(client));
  }

  async create(client: ClientEntity): Promise<ClientEntity> {
    const createdClient = await this.prisma.client.create({
      data: {
        id: client.id.value,
        firstName: client.firstName,
        lastName: client.lastName,
        documentNumber: client.documentNumber.value,
        phone: client.phone,
        email: client.email,
        address: client.address,
        notes: client.notes,
        createdAt: client.createdAt,
        updatedAt: client.updatedAt,
      },
    });

    return ClientPrismaMapper.toDomain(createdClient);
  }

  async update(client: ClientEntity): Promise<ClientEntity> {
    const updatedClient = await this.prisma.client.update({
      where: { id: client.id.value },
      data: {
        firstName: client.firstName,
        lastName: client.lastName,
        documentNumber: client.documentNumber.value,
        phone: client.phone,
        email: client.email,
        address: client.address,
        notes: client.notes,
      },
    });

    return ClientPrismaMapper.toDomain(updatedClient);
  }
}
