import { Inject, Injectable } from '@nestjs/common';
import { UseCase } from '../../../../../shared/application/use-case';
import {
  AUDIT_LOG_REPOSITORY,
  AuditLogRepository,
} from '../../../domain/repositories/audit-log.repository';
import { AuditLogDto, toAuditLogDto } from '../../dto/audit-log.dto';

export type GetCaseHistoryQuery = {
  caseFileId: string;
};

@Injectable()
export class GetCaseHistoryUseCase
  implements UseCase<GetCaseHistoryQuery, AuditLogDto[]>
{
  constructor(
    @Inject(AUDIT_LOG_REPOSITORY)
    private readonly auditLogRepository: AuditLogRepository,
  ) {}

  async execute(query: GetCaseHistoryQuery): Promise<AuditLogDto[]> {
    const auditLogs = await this.auditLogRepository.search({
      caseFileId: query.caseFileId.trim(),
    });

    return auditLogs.map(toAuditLogDto);
  }
}
