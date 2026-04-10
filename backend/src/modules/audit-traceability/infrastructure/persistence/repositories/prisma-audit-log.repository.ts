import { Injectable } from '@nestjs/common';
import { Prisma, AuditEntityType as PrismaAuditEntityType } from '@prisma/client';
import { PrismaService } from '../../../../../shared/infrastructure/prisma/prisma.service';
import { AuditEntityType, AuditLogEntity } from '../../../domain/entities/audit-log.entity';
import {
  AuditLogRepository,
  SearchAuditLogsFilters,
} from '../../../domain/repositories/audit-log.repository';
import { AuditLogPrismaMapper } from '../mappers/audit-log-prisma.mapper';

@Injectable()
export class PrismaAuditLogRepository implements AuditLogRepository {
  constructor(private readonly prisma: PrismaService) {}

  async create(auditLog: AuditLogEntity): Promise<AuditLogEntity> {
    const createdAuditLog = await this.prisma.auditLog.create({
      data: {
        id: auditLog.id,
        entityType: auditLog.entityType as PrismaAuditEntityType,
        entityId: auditLog.entityId,
        caseFileId: auditLog.caseFileId,
        action: auditLog.action,
        performedById: auditLog.performedById,
        metadata: AuditLogPrismaMapper.toPersistenceMetadata(auditLog.metadata),
        createdAt: auditLog.createdAt,
      },
    });

    return AuditLogPrismaMapper.toDomain(createdAuditLog);
  }

  async search(filters: SearchAuditLogsFilters): Promise<AuditLogEntity[]> {
    const where: Prisma.AuditLogWhereInput = {};

    if (filters.caseFileId) {
      where.caseFileId = filters.caseFileId;
    }

    if (filters.entityType) {
      where.entityType = filters.entityType as PrismaAuditEntityType;
    }

    if (filters.entityId) {
      where.entityId = filters.entityId;
    }

    const auditLogs = await this.prisma.auditLog.findMany({
      where,
      orderBy: [{ createdAt: 'desc' }],
    });

    return auditLogs.map((auditLog) => AuditLogPrismaMapper.toDomain(auditLog));
  }
}
