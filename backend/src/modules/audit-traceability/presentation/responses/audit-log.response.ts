import { AuditLogDto } from '../../application/dto/audit-log.dto';
import { AuditEntityType } from '../../domain/entities/audit-log.entity';

export class AuditLogResponse {
  id!: string;
  entityType!: AuditEntityType;
  entityId!: string;
  caseFileId!: string | null;
  action!: string;
  performedById!: string | null;
  metadata!: Record<string, unknown> | null;
  createdAt!: Date;

  static fromDto(dto: AuditLogDto): AuditLogResponse {
    return {
      id: dto.id,
      entityType: dto.entityType,
      entityId: dto.entityId,
      caseFileId: dto.caseFileId,
      action: dto.action,
      performedById: dto.performedById,
      metadata: dto.metadata,
      createdAt: dto.createdAt,
    };
  }
}
