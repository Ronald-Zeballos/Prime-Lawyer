import { AuditLog as PrismaAuditLogModel, Prisma } from '@prisma/client';
import { AuditLogEntity } from '../../../domain/entities/audit-log.entity';

export class AuditLogPrismaMapper {
  static toDomain(auditLog: PrismaAuditLogModel): AuditLogEntity {
    return AuditLogEntity.create({
      id: auditLog.id,
      entityType: auditLog.entityType,
      entityId: auditLog.entityId,
      caseFileId: auditLog.caseFileId,
      action: auditLog.action,
      performedById: auditLog.performedById,
      metadata: AuditLogPrismaMapper.toMetadata(auditLog.metadata),
      createdAt: auditLog.createdAt,
    });
  }

  static toPersistenceMetadata(
    metadata: Record<string, unknown> | null,
  ): Prisma.InputJsonObject | typeof Prisma.DbNull {
    if (!metadata) {
      return Prisma.DbNull;
    }

    return metadata as Prisma.InputJsonObject;
  }

  private static toMetadata(
    value: PrismaAuditLogModel['metadata'],
  ): Record<string, unknown> | null {
    if (value === null) {
      return null;
    }

    if (typeof value !== 'object' || Array.isArray(value)) {
      throw new Error('Audit log metadata must be a JSON object.');
    }

    return value as Record<string, unknown>;
  }
}
