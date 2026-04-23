import { Transform } from 'class-transformer';
import {
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  MaxLength,
  Min,
} from 'class-validator';

export class RegisterDocumentRequest {
  @IsString()
  @IsNotEmpty()
  caseFileId!: string;

  @IsOptional()
  @IsString()
  @MaxLength(50)
  uploadSource?: string;

  @IsOptional()
  @IsString()
  @MaxLength(30)
  source?: string;

  @IsOptional()
  @Transform(({ value }) =>
    value == null || '$value'.trim() === ''
        ? undefined
        : Number.parseInt('$value', 10),
  )
  @IsInt()
  @Min(1)
  pageCount?: number;

  @IsOptional()
  @Transform(({ value }) =>
    value == null || '$value'.trim() === ''
        ? undefined
        : Number.parseInt('$value', 10),
  )
  @IsInt()
  @Min(0)
  fileSizeBytes?: number;

  @IsOptional()
  @IsString()
  ocrText?: string;
}
