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

export type DeleteClientCommand = {
  id: string;
  performedById: string;
};

@Injectable()
export class DeleteClientUseCase
  implements UseCase<DeleteClientCommand, void>
{
  constructor(
    @Inject(CLIENT_REPOSITORY)
    private readonly clientRepository: ClientRepository,
    private readonly registerAuditEventUseCase: RegisterAuditEventUseCase,
  ) {}

  async execute(command: DeleteClientCommand): Promise<void> {
    const clientId = ClientId.create(command.id);
    const client = await this.clientRepository.findById(clientId);

    if (!client) {
      throw new NotFoundError('Client was not found.');
    }

    const linkedCaseFilesCount =
      await this.clientRepository.countLinkedCaseFiles(clientId);

    if (linkedCaseFilesCount > 0) {
      throw new ConflictError(
        'No se puede eliminar este cliente porque tiene casos asociados.',
      );
    }

    await this.clientRepository.delete(clientId);

    await this.registerAuditEventUseCase.execute({
      entityType: AuditEntityType.CLIENT,
      entityId: client.id.value,
      action: 'CLIENT_DELETED',
      performedById: command.performedById,
      metadata: {
        fullName: `${client.firstName} ${client.lastName}`.trim(),
        documentNumber: client.documentNumber.value,
      },
    });
  }
}
