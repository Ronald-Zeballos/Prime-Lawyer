import { Type } from 'class-transformer';
import {
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
} from 'class-validator';

export class AskContextualLegalQuestionRequest {
  @IsString()
  @IsNotEmpty()
  @MaxLength(2000)
  question!: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  caseFileId?: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  documentId?: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  processType?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(5)
  limit?: number;
}
