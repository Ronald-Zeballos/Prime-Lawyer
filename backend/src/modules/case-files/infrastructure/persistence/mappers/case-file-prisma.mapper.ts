import { CaseFile as PrismaCaseFileModel, CaseStatus as PrismaCaseStatus, ConfidentialityLevel as PrismaConfidentialityLevel } from '@prisma/client';
import { CaseFileEntity } from '../../../domain/entities/case-file.entity';
import { CaseStatus } from '../../../domain/value-objects/case-status.vo';
import { ConfidentialityLevel } from '../../../domain/value-objects/confidentiality-level.vo';

export class CaseFilePrismaMapper {
  static toDomain(caseFile: PrismaCaseFileModel): CaseFileEntity {
    return CaseFileEntity.create({
      id: caseFile.id,
      internalCode: caseFile.internalCode,
      clientId: caseFile.clientId,
      subject: caseFile.subject,
      processType: caseFile.processType,
      status: this.toCaseStatus(caseFile.status),
      responsibleUserId: caseFile.responsibleUserId,
      openedAt: caseFile.openedAt,
      closedAt: caseFile.closedAt,
      confidentialityLevel: this.toConfidentialityLevel(
        caseFile.confidentialityLevel,
      ),
      createdAt: caseFile.createdAt,
      updatedAt: caseFile.updatedAt,
    });
  }

  private static toCaseStatus(status: PrismaCaseStatus): CaseStatus {
    switch (status) {
      case PrismaCaseStatus.OPEN:
        return CaseStatus.OPEN;
      case PrismaCaseStatus.IN_PROGRESS:
        return CaseStatus.IN_PROGRESS;
      case PrismaCaseStatus.CLOSED:
        return CaseStatus.CLOSED;
      case PrismaCaseStatus.ARCHIVED:
        return CaseStatus.ARCHIVED;
      default:
        throw new Error(`Unsupported case status: ${status}`);
    }
  }

  private static toConfidentialityLevel(
    confidentialityLevel: PrismaConfidentialityLevel,
  ): ConfidentialityLevel {
    switch (confidentialityLevel) {
      case PrismaConfidentialityLevel.STANDARD:
        return ConfidentialityLevel.STANDARD;
      case PrismaConfidentialityLevel.CONFIDENTIAL:
        return ConfidentialityLevel.CONFIDENTIAL;
      case PrismaConfidentialityLevel.HIGHLY_CONFIDENTIAL:
        return ConfidentialityLevel.HIGHLY_CONFIDENTIAL;
      default:
        throw new Error(
          `Unsupported confidentiality level: ${confidentialityLevel}`,
        );
    }
  }
}
