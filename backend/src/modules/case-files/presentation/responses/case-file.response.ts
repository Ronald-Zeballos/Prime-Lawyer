import { CaseFileDto } from '../../application/dto/case-file.dto';
import { CaseStatus } from '../../domain/value-objects/case-status.vo';
import { ConfidentialityLevel } from '../../domain/value-objects/confidentiality-level.vo';

export class CaseFileResponse {
  id!: string;
  internalCode!: string;
  clientId!: string;
  subject!: string;
  processType!: string;
  status!: CaseStatus;
  responsibleUserId!: string | null;
  openedAt!: Date;
  closedAt!: Date | null;
  confidentialityLevel!: ConfidentialityLevel;
  createdAt!: Date;
  updatedAt!: Date;

  static fromDto(dto: CaseFileDto): CaseFileResponse {
    return {
      id: dto.id,
      internalCode: dto.internalCode,
      clientId: dto.clientId,
      subject: dto.subject,
      processType: dto.processType,
      status: dto.status,
      responsibleUserId: dto.responsibleUserId,
      openedAt: dto.openedAt,
      closedAt: dto.closedAt,
      confidentialityLevel: dto.confidentialityLevel,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    };
  }
}
