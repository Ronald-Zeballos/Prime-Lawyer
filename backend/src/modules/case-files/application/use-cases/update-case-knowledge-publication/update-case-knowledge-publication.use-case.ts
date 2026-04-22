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

export type UpdateCaseKnowledgePublicationCommand = {
  id: string;
  publish: boolean;
  performedById: string;
};

@Injectable()
export class UpdateCaseKnowledgePublicationUseCase
  implements UseCase<UpdateCaseKnowledgePublicationCommand, CaseFileDto>
{
  constructor(
    @Inject(CASE_FILE_REPOSITORY)
    private readonly caseFileRepository: CaseFileRepository,
    private readonly registerAuditEventUseCase: RegisterAuditEventUseCase,
  ) {}

  async execute(
    command: UpdateCaseKnowledgePublicationCommand,
  ): Promise<CaseFileDto> {
    const caseFile = await this.caseFileRepository.findById(
      CaseFileId.create(command.id),
    );

    if (!caseFile) {
      throw new NotFoundError('Case file was not found.');
    }

    if (!caseFile.belongsTo(command.performedById)) {
      throw new ForbiddenError(
        'This case file cannot be updated by the current user.',
      );
    }

    const previousVisibility = caseFile.visibility;
    const previousKnowledgeStatus = caseFile.knowledgeStatus;

    if (command.publish) {
      caseFile.publishToRepository();
    } else {
      caseFile.unpublishFromRepository();
    }

    const updatedCaseFile = await this.caseFileRepository.update(caseFile);

    await this.registerAuditEventUseCase.execute({
      entityType: AuditEntityType.CASE_FILE,
      entityId: updatedCaseFile.id.value,
      caseFileId: updatedCaseFile.id.value,
      action: command.publish
        ? 'CASE_FILE_PUBLISHED_TO_REPOSITORY'
        : 'CASE_FILE_REMOVED_FROM_REPOSITORY',
      performedById: command.performedById,
      metadata: {
        title: updatedCaseFile.title,
        previousVisibility,
        currentVisibility: updatedCaseFile.visibility,
        previousKnowledgeStatus,
        currentKnowledgeStatus: updatedCaseFile.knowledgeStatus,
        publishedAt: updatedCaseFile.publishedAt?.toISOString() ?? null,
      },
    });

    return toCaseFileDto(updatedCaseFile);
  }
}
