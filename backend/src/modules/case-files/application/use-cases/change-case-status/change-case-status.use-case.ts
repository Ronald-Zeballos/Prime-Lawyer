import { Inject, Injectable } from '@nestjs/common';
import { ForbiddenError } from '../../../../../shared/application/errors/forbidden.error';
import { NotFoundError } from '../../../../../shared/application/errors/not-found.error';
import { UseCase } from '../../../../../shared/application/use-case';
import {
  AuditEntityType,
} from '../../../../audit-traceability/domain/entities/audit-log.entity';
import { RegisterAuditEventUseCase } from '../../../../audit-traceability/application/use-cases/register-audit-event/register-audit-event.use-case';
import {
  CASE_FILE_REPOSITORY,
  CaseFileRepository,
} from '../../../domain/repositories/case-file.repository';
import { CaseFileId } from '../../../domain/value-objects/case-file-id.vo';
import { CaseFileDto, toCaseFileDto } from '../../dto/case-file.dto';

export type ChangeCaseStatusCommand = {
  id: string;
  status: string;
  performedById: string;
};

@Injectable()
export class ChangeCaseStatusUseCase
  implements UseCase<ChangeCaseStatusCommand, CaseFileDto>
{
  constructor(
    @Inject(CASE_FILE_REPOSITORY)
    private readonly caseFileRepository: CaseFileRepository,
    private readonly registerAuditEventUseCase: RegisterAuditEventUseCase,
  ) {}

  async execute(command: ChangeCaseStatusCommand): Promise<CaseFileDto> {
    const caseFile = await this.caseFileRepository.findById(
      CaseFileId.create(command.id),
    );

    if (!caseFile) {
      throw new NotFoundError('Case file was not found.');
    }

    if (!caseFile.belongsTo(command.performedById)) {
      throw new ForbiddenError('This case file cannot be updated by the current user.');
    }

    const previousStatus = caseFile.status.value;
    caseFile.changeStatus(command.status);

    const updatedCaseFile = await this.caseFileRepository.update(caseFile);

    await this.registerAuditEventUseCase.execute({
      entityType: AuditEntityType.CASE_FILE,
      entityId: updatedCaseFile.id.value,
      caseFileId: updatedCaseFile.id.value,
      action: 'CASE_FILE_STATUS_CHANGED',
      performedById: command.performedById,
      metadata: {
        title: updatedCaseFile.title,
        previousStatus,
        currentStatus: updatedCaseFile.status.value,
      },
    });

    return toCaseFileDto(updatedCaseFile);
  }
}
