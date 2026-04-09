import { IsEnum } from 'class-validator';
import { CaseStatus } from '../../domain/value-objects/case-status.vo';

export class ChangeCaseStatusRequest {
  @IsEnum(CaseStatus)
  status!: CaseStatus;
}
