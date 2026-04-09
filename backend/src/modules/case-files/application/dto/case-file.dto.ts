import { CaseFileEntity } from '../../domain/entities/case-file.entity';
import { CaseStatus } from '../../domain/value-objects/case-status.vo';
import {
  ConfidentialityLevel,
} from '../../domain/value-objects/confidentiality-level.vo';

export type CaseFileDto = {
  id: string;
  internalCode: string;
  clientId: string;
  subject: string;
  processType: string;
  status: CaseStatus;
  responsibleUserId: string | null;
  openedAt: Date;
  closedAt: Date | null;
  confidentialityLevel: ConfidentialityLevel;
  createdAt: Date;
  updatedAt: Date;
};

export function toCaseFileDto(caseFile: CaseFileEntity): CaseFileDto {
  return {
    id: caseFile.id.value,
    internalCode: caseFile.internalCode,
    clientId: caseFile.clientId,
    subject: caseFile.subject,
    processType: caseFile.processType,
    status: caseFile.status.value,
    responsibleUserId: caseFile.responsibleUserId,
    openedAt: caseFile.openedAt,
    closedAt: caseFile.closedAt,
    confidentialityLevel: caseFile.confidentialityLevel.value,
    createdAt: caseFile.createdAt,
    updatedAt: caseFile.updatedAt,
  };
}
