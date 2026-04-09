import { randomUUID } from 'node:crypto';
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
} from '../../../../clients/domain/repositories/client.repository';
import { ClientId } from '../../../../clients/domain/value-objects/client-id.vo';
import {
  USER_REPOSITORY,
  UserRepository,
} from '../../../../identity-access/domain/repositories/user.repository';
import { UserId } from '../../../../identity-access/domain/value-objects/user-id.vo';
import { CaseFileEntity } from '../../../domain/entities/case-file.entity';
import {
  CASE_FILE_REPOSITORY,
  CaseFileRepository,
} from '../../../domain/repositories/case-file.repository';
import { CaseFileDto, toCaseFileDto } from '../../dto/case-file.dto';

export type CreateCaseFileCommand = {
  internalCode: string;
  clientId: string;
  subject: string;
  processType: string;
  responsibleUserId?: string | null;
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
    @Inject(USER_REPOSITORY)
    private readonly userRepository: UserRepository,
    private readonly registerAuditEventUseCase: RegisterAuditEventUseCase,
  ) {}

  async execute(command: CreateCaseFileCommand): Promise<CaseFileDto> {
    const existingCaseFile = await this.caseFileRepository.findByInternalCode(
      command.internalCode.trim(),
    );

    if (existingCaseFile) {
      throw new ConflictError('A case file with this internal code already exists.');
    }

    const client = await this.clientRepository.findById(
      ClientId.create(command.clientId),
    );

    if (!client) {
      throw new NotFoundError('Client was not found.');
    }

    if (command.responsibleUserId) {
      const responsibleUser = await this.userRepository.findById(
        UserId.create(command.responsibleUserId),
      );

      if (!responsibleUser) {
        throw new NotFoundError('Responsible user was not found.');
      }
    }

    const caseFile = CaseFileEntity.create({
      id: randomUUID(),
      internalCode: command.internalCode,
      clientId: command.clientId,
      subject: command.subject,
      processType: command.processType,
      responsibleUserId: command.responsibleUserId,
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
        internalCode: createdCaseFile.internalCode,
        clientId: createdCaseFile.clientId,
        responsibleUserId: createdCaseFile.responsibleUserId,
        status: createdCaseFile.status.value,
      },
    });

    return toCaseFileDto(createdCaseFile);
  }
}
