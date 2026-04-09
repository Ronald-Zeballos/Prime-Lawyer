import {
  IsEnum,
  IsNotEmpty,
  IsOptional,
  IsString,
  MaxLength,
} from 'class-validator';
import { AuditEntityType } from '../../domain/entities/audit-log.entity';

export class SearchAuditLogsRequest {
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  caseFileId?: string;

  @IsOptional()
  @IsEnum(AuditEntityType)
  entityType?: AuditEntityType;

  @IsOptional()
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  entityId?: string;
}
