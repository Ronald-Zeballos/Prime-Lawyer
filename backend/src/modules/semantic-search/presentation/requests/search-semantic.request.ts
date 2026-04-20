import { Type } from 'class-transformer';
import {
  IsInt,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
} from 'class-validator';

export class SearchSemanticRequest {
  @IsOptional()
  @IsString()
  @MaxLength(2000)
  text?: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  processType?: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  caseFileId?: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  documentId?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(10)
  limit?: number;
}
