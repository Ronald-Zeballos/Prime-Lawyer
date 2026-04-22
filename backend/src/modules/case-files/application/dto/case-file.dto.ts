import { CaseFileEntity } from '../../domain/entities/case-file.entity';
import {
  CaseVisibility,
  KnowledgeStatus,
} from '../../domain/entities/case-file.entity';
import { CaseStatus } from '../../domain/value-objects/case-status.vo';
import {
  ConfidentialityLevel,
} from '../../domain/value-objects/confidentiality-level.vo';

export type CaseFileDto = {
  id: string;
  internalCode: string;
  ownerUserId: string;
  title: string;
  description: string | null;
  processType: string;
  status: CaseStatus;
  responsibleUserId: string | null;
  openedAt: Date;
  closedAt: Date | null;
  visibility: CaseVisibility;
  knowledgeStatus: KnowledgeStatus;
  publishedAt: Date | null;
  confidentialityLevel: ConfidentialityLevel;
  createdAt: Date;
  updatedAt: Date;
};

export function toCaseFileDto(caseFile: CaseFileEntity): CaseFileDto {
  return {
    id: caseFile.id.value,
    internalCode: caseFile.internalCode,
    ownerUserId: caseFile.ownerUserId,
    title: caseFile.title,
    description: caseFile.description,
    processType: caseFile.processType,
    status: caseFile.status.value,
    responsibleUserId: caseFile.responsibleUserId,
    openedAt: caseFile.openedAt,
    closedAt: caseFile.closedAt,
    visibility: caseFile.visibility,
    knowledgeStatus: caseFile.knowledgeStatus,
    publishedAt: caseFile.publishedAt,
    confidentialityLevel: caseFile.confidentialityLevel.value,
    createdAt: caseFile.createdAt,
    updatedAt: caseFile.updatedAt,
  };
}
