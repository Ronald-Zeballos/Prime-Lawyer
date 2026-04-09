import { Inject, Injectable } from '@nestjs/common';
import { ConflictError } from '../../../../../shared/application/errors/conflict.error';
import { NotFoundError } from '../../../../../shared/application/errors/not-found.error';
import { UseCase } from '../../../../../shared/application/use-case';
import {
  AuditEntityType,
} from '../../../../audit-traceability/domain/entities/audit-log.entity';
import { RegisterAuditEventUseCase } from '../../../../audit-traceability/application/use-cases/register-audit-event/register-audit-event.use-case';
import {
  CLIENT_REPOSITORY,
  ClientRepository,
} from '../../../domain/repositories/client.repository';
import { ClientId } from '../../../domain/value-objects/client-id.vo';
import { DocumentNumber } from '../../../domain/value-objects/document-number.vo';
import { ClientDto, toClientDto } from '../../dto/client.dto';

export type UpdateClientCommand = {
  id: string;
  firstName?: string;
  lastName?: string;
  documentNumber?: string;
  phone?: string | null;
  email?: string | null;
  address?: string | null;
  notes?: string | null;
  performedById: string;
};

@Injectable()
export class UpdateClientUseCase
  implements UseCase<UpdateClientCommand, ClientDto>
{
  constructor(
    @Inject(CLIENT_REPOSITORY)
    private readonly clientRepository: ClientRepository,
    private readonly registerAuditEventUseCase: RegisterAuditEventUseCase,
  ) {}

  async execute(command: UpdateClientCommand): Promise<ClientDto> {
    const client = await this.clientRepository.findById(ClientId.create(command.id));

    if (!client) {
      throw new NotFoundError('Client was not found.');
    }

    if (command.documentNumber !== undefined) {
      const documentNumber = DocumentNumber.create(command.documentNumber);
      const existingClient = await this.clientRepository.findByDocumentNumber(
        documentNumber,
      );

      if (existingClient && existingClient.id.value !== client.id.value) {
        throw new ConflictError(
          'A client with this document number already exists.',
        );
      }
    }

    const updatedFields = Object.entries({
      firstName: command.firstName,
      lastName: command.lastName,
      documentNumber: command.documentNumber,
      phone: command.phone,
      email: command.email,
      address: command.address,
      notes: command.notes,
    })
      .filter(([, value]) => value !== undefined)
      .map(([field]) => field);

    client.update({
      firstName: command.firstName,
      lastName: command.lastName,
      documentNumber: command.documentNumber,
      phone: command.phone,
      email: command.email,
      address: command.address,
      notes: command.notes,
    });

    const updatedClient = await this.clientRepository.update(client);

    await this.registerAuditEventUseCase.execute({
      entityType: AuditEntityType.CLIENT,
      entityId: updatedClient.id.value,
      action: 'CLIENT_UPDATED',
      performedById: command.performedById,
      metadata: {
        updatedFields,
      },
    });

    return toClientDto(updatedClient);
  }
}
