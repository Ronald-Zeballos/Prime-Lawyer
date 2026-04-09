import { randomUUID } from 'node:crypto';
import { Inject, Injectable } from '@nestjs/common';
import { ConflictError } from '../../../../../shared/application/errors/conflict.error';
import { UseCase } from '../../../../../shared/application/use-case';
import {
  AuditEntityType,
} from '../../../../audit-traceability/domain/entities/audit-log.entity';
import { RegisterAuditEventUseCase } from '../../../../audit-traceability/application/use-cases/register-audit-event/register-audit-event.use-case';
import { ClientEntity } from '../../../domain/entities/client.entity';
import {
  CLIENT_REPOSITORY,
  ClientRepository,
} from '../../../domain/repositories/client.repository';
import { DocumentNumber } from '../../../domain/value-objects/document-number.vo';
import { ClientDto, toClientDto } from '../../dto/client.dto';

export type CreateClientCommand = {
  firstName: string;
  lastName: string;
  documentNumber: string;
  phone?: string | null;
  email?: string | null;
  address?: string | null;
  notes?: string | null;
  performedById: string;
};

@Injectable()
export class CreateClientUseCase
  implements UseCase<CreateClientCommand, ClientDto>
{
  constructor(
    @Inject(CLIENT_REPOSITORY)
    private readonly clientRepository: ClientRepository,
    private readonly registerAuditEventUseCase: RegisterAuditEventUseCase,
  ) {}

  async execute(command: CreateClientCommand): Promise<ClientDto> {
    const documentNumber = DocumentNumber.create(command.documentNumber);
    const existingClient = await this.clientRepository.findByDocumentNumber(
      documentNumber,
    );

    if (existingClient) {
      throw new ConflictError('A client with this document number already exists.');
    }

    const client = ClientEntity.create({
      id: randomUUID(),
      firstName: command.firstName,
      lastName: command.lastName,
      documentNumber: documentNumber.value,
      phone: command.phone,
      email: command.email,
      address: command.address,
      notes: command.notes,
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    const createdClient = await this.clientRepository.create(client);

    await this.registerAuditEventUseCase.execute({
      entityType: AuditEntityType.CLIENT,
      entityId: createdClient.id.value,
      action: 'CLIENT_CREATED',
      performedById: command.performedById,
      metadata: {
        firstName: createdClient.firstName,
        lastName: createdClient.lastName,
        documentNumber: createdClient.documentNumber.value,
      },
    });

    return toClientDto(createdClient);
  }
}
