import { CaseFile as PrismaCaseFileModel, CaseStatus as PrismaCaseStatus, CaseVisibility as PrismaCaseVisibility, ConfidentialityLevel as PrismaConfidentialityLevel, KnowledgeStatus as PrismaKnowledgeStatus } from '@prisma/client';
import {
  CaseFileEntity,
  CaseVisibility,
  KnowledgeStatus,
} from '../../../domain/entities/case-file.entity';
import { CaseStatus } from '../../../domain/value-objects/case-status.vo';
import { ConfidentialityLevel } from '../../../domain/value-objects/confidentiality-level.vo';

export class CaseFilePrismaMapper {
  static toDomain(caseFile: PrismaCaseFileModel): CaseFileEntity {
    return CaseFileEntity.create({
      id: caseFile.id,
      internalCode: caseFile.internalCode,
      ownerUserId:
        caseFile.ownerUserId ?? caseFile.responsibleUserId ?? caseFile.id,
      title: caseFile.title ?? caseFile.subject ?? caseFile.internalCode,
      description: caseFile.description,
      processType: caseFile.processType,
      status: CaseFilePrismaMapper.toCaseStatus(caseFile.status),
      responsibleUserId: caseFile.responsibleUserId,
      openedAt: caseFile.openedAt,
      closedAt: caseFile.closedAt,
      visibility: CaseFilePrismaMapper.toCaseVisibility(caseFile.visibility),
      knowledgeStatus: CaseFilePrismaMapper.toKnowledgeStatus(
        caseFile.knowledgeStatus,
      ),
      publishedAt: caseFile.publishedAt,
      confidentialityLevel: CaseFilePrismaMapper.toConfidentialityLevel(
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

  private static toCaseVisibility(
    visibility: PrismaCaseVisibility,
  ): CaseVisibility {
    switch (visibility) {
      case PrismaCaseVisibility.PRIVATE:
        return CaseVisibility.PRIVATE;
      case PrismaCaseVisibility.COMMUNITY:
        return CaseVisibility.COMMUNITY;
      default:
        throw new Error(`Unsupported case visibility: ${visibility}`);
    }
  }

  private static toKnowledgeStatus(
    knowledgeStatus: PrismaKnowledgeStatus,
  ): KnowledgeStatus {
    switch (knowledgeStatus) {
      case PrismaKnowledgeStatus.DRAFT:
        return KnowledgeStatus.DRAFT;
      case PrismaKnowledgeStatus.ELIGIBLE:
        return KnowledgeStatus.ELIGIBLE;
      case PrismaKnowledgeStatus.PUBLISHED:
        return KnowledgeStatus.PUBLISHED;
      case PrismaKnowledgeStatus.EXCLUDED:
        return KnowledgeStatus.EXCLUDED;
      default:
        throw new Error(`Unsupported knowledge status: ${knowledgeStatus}`);
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
