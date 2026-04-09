import { Inject, Injectable } from '@nestjs/common';
import { UseCase } from '../../../../../shared/application/use-case';
import { AuditEntityType } from '../../../domain/entities/audit-log.entity';
import {
  AUDIT_LOG_REPOSITORY,
  AuditLogRepository,
} from '../../../domain/repositories/audit-log.repository';
import { AuditLogDto, toAuditLogDto } from '../../dto/audit-log.dto';

export type GetEntityHistoryQuery = {
  entityType: AuditEntityType;
  entityId: string;
};

@Injectable()
export class GetEntityHistoryUseCase
  implements UseCase<GetEntityHistoryQuery, AuditLogDto[]>
{
  constructor(
    @Inject(AUDIT_LOG_REPOSITORY)
    private readonly auditLogRepository: AuditLogRepository,
  ) {}

  async execute(query: GetEntityHistoryQuery): Promise<AuditLogDto[]> {
    const auditLogs = await this.auditLogRepository.search({
      entityType: query.entityType,
      entityId: query.entityId.trim(),
    });

    return auditLogs.map(toAuditLogDto);
  }
}
