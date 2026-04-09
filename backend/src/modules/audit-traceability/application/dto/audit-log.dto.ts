import { AuditEntityType, AuditLogEntity } from '../../domain/entities/audit-log.entity';

export type AuditLogDto = {
  id: string;
  entityType: AuditEntityType;
  entityId: string;
  caseFileId: string | null;
  action: string;
  performedById: string | null;
  metadata: Record<string, unknown> | null;
  createdAt: Date;
};

export function toAuditLogDto(auditLog: AuditLogEntity): AuditLogDto {
  return {
    id: auditLog.id,
    entityType: auditLog.entityType,
    entityId: auditLog.entityId,
    caseFileId: auditLog.caseFileId,
    action: auditLog.action,
    performedById: auditLog.performedById,
    metadata: auditLog.metadata,
    createdAt: auditLog.createdAt,
  };
}
