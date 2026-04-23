import { randomUUID } from 'node:crypto';
import { Inject, Injectable } from '@nestjs/common';
import { ConflictError } from '../../../../../shared/application/errors/conflict.error';
import { NotFoundError } from '../../../../../shared/application/errors/not-found.error';
import { UseCase } from '../../../../../shared/application/use-case';
import {
  AuditEntityType,
} from '../../../../audit-traceability/domain/entities/audit-log.entity';
import { RegisterAuditEventUseCase } from '../../../../audit-traceability/application/use-cases/register-audit-event/register-audit-event.use-case';
import { CaseFileEntity } from '../../../domain/entities/case-file.entity';
import {
  CASE_FILE_REPOSITORY,
  CaseFileRepository,
} from '../../../domain/repositories/case-file.repository';
import { CaseFileDto, toCaseFileDto } from '../../dto/case-file.dto';
import {
  CLIENT_REPOSITORY,
  ClientRepository,
} from '../../../../clients/domain/repositories/client.repository';
import { ClientId } from '../../../../clients/domain/value-objects/client-id.vo';

export type CreateCaseFileCommand = {
  clientId: string;
  internalCode: string;
  title: string;
  description?: string | null;
  processType: string;
  confidentialityLevel?: string;
  performedById: string;
};

@Injectable()
export class CreateCaseFileUseCase
  implements UseCase<CreateCaseFileCommand, CaseFileDto>
{
  constructor(
    @Inject(CASE_FILE_REPOSITORY)
    private readonly caseFileRepository: CaseFileRepository,
    @Inject(CLIENT_REPOSITORY)
    private readonly clientRepository: ClientRepository,
    private readonly registerAuditEventUseCase: RegisterAuditEventUseCase,
  ) {}

  async execute(command: CreateCaseFileCommand): Promise<CaseFileDto> {
    const client = await this.clientRepository.findById(
      ClientId.create(command.clientId),
    );

    if (!client) {
      throw new NotFoundError('Client was not found.');
    }

    const existingCaseFile = await this.caseFileRepository.findByInternalCode(
      command.internalCode.trim(),
    );

    if (existingCaseFile) {
      throw new ConflictError('A case file with this internal code already exists.');
    }

    const caseFile = CaseFileEntity.create({
      id: randomUUID(),
      internalCode: command.internalCode,
      clientId: client.id.value,
      ownerUserId: command.performedById,
      title: command.title,
      description: command.description,
      processType: command.processType,
      confidentialityLevel: command.confidentialityLevel,
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    const createdCaseFile = await this.caseFileRepository.create(caseFile);

    await this.registerAuditEventUseCase.execute({
      entityType: AuditEntityType.CASE_FILE,
      entityId: createdCaseFile.id.value,
      caseFileId: createdCaseFile.id.value,
      action: 'CASE_FILE_CREATED',
      performedById: command.performedById,
      metadata: {
        clientId: createdCaseFile.clientId,
        internalCode: createdCaseFile.internalCode,
        ownerUserId: createdCaseFile.ownerUserId,
        title: createdCaseFile.title,
        processType: createdCaseFile.processType,
        status: createdCaseFile.status.value,
      },
    });

    return toCaseFileDto(createdCaseFile);
  }
}
