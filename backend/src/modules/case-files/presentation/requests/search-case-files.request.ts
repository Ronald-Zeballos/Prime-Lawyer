import { IsEnum, IsOptional, IsString, MaxLength } from 'class-validator';
import { CaseStatus } from '../../domain/value-objects/case-status.vo';

export class SearchCaseFilesRequest {
  @IsOptional()
  @IsString()
  @MaxLength(100)
  term?: string;

  @IsOptional()
  @IsEnum(CaseStatus)
  status?: CaseStatus;
}
