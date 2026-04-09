import { randomUUID } from 'node:crypto';
import { Inject, Injectable } from '@nestjs/common';
import { UseCase } from '../../../../../shared/application/use-case';
import { AuditEntityType, AuditLogEntity } from '../../../domain/entities/audit-log.entity';
import {
  AUDIT_LOG_REPOSITORY,
  AuditLogRepository,
} from '../../../domain/repositories/audit-log.repository';

export type RegisterAuditEventCommand = {
  entityType: AuditEntityType;
  entityId: string;
  caseFileId?: string | null;
  action: string;
  performedById?: string | null;
  metadata?: Record<string, unknown> | null;
};

@Injectable()
export class RegisterAuditEventUseCase
  implements UseCase<RegisterAuditEventCommand, void>
{
  constructor(
    @Inject(AUDIT_LOG_REPOSITORY)
    private readonly auditLogRepository: AuditLogRepository,
  ) {}

  async execute(command: RegisterAuditEventCommand): Promise<void> {
    const auditLog = AuditLogEntity.create({
      id: randomUUID(),
      entityType: command.entityType,
      entityId: command.entityId,
      caseFileId: command.caseFileId,
      action: command.action,
      performedById: command.performedById,
      metadata: command.metadata,
      createdAt: new Date(),
    });

    await this.auditLogRepository.create(auditLog);
  }
}
