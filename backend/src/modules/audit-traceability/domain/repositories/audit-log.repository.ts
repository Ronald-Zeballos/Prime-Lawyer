import { AuditEntityType, AuditLogEntity } from '../entities/audit-log.entity';

export const AUDIT_LOG_REPOSITORY = Symbol('AUDIT_LOG_REPOSITORY');

export type SearchAuditLogsFilters = {
  caseFileId?: string;
  entityType?: AuditEntityType;
  entityId?: string;
};

export interface AuditLogRepository {
  create(auditLog: AuditLogEntity): Promise<AuditLogEntity>;
  search(filters: SearchAuditLogsFilters): Promise<AuditLogEntity[]>;
}
