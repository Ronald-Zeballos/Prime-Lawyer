import { CaseFileDto } from '../../application/dto/case-file.dto';
import {
  CaseVisibility,
  KnowledgeStatus,
} from '../../domain/entities/case-file.entity';
import { CaseStatus } from '../../domain/value-objects/case-status.vo';
import { ConfidentialityLevel } from '../../domain/value-objects/confidentiality-level.vo';

export class CaseFileResponse {
  id!: string;
  internalCode!: string;
  ownerUserId!: string;
  title!: string;
  description!: string | null;
  processType!: string;
  status!: CaseStatus;
  responsibleUserId!: string | null;
  openedAt!: Date;
  closedAt!: Date | null;
  visibility!: CaseVisibility;
  knowledgeStatus!: KnowledgeStatus;
  confidentialityLevel!: ConfidentialityLevel;
  createdAt!: Date;
  updatedAt!: Date;

  static fromDto(dto: CaseFileDto): CaseFileResponse {
    return {
      id: dto.id,
      internalCode: dto.internalCode,
      ownerUserId: dto.ownerUserId,
      title: dto.title,
      description: dto.description,
      processType: dto.processType,
      status: dto.status,
      responsibleUserId: dto.responsibleUserId,
      openedAt: dto.openedAt,
      closedAt: dto.closedAt,
      visibility: dto.visibility,
      knowledgeStatus: dto.knowledgeStatus,
      confidentialityLevel: dto.confidentialityLevel,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    };
  }
}
