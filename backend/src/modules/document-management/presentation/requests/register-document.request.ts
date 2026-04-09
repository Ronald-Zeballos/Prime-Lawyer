import { IsNotEmpty, IsOptional, IsString, MaxLength } from 'class-validator';

export class RegisterDocumentRequest {
  @IsString()
  @IsNotEmpty()
  caseFileId!: string;

  @IsOptional()
  @IsString()
  @MaxLength(50)
  uploadSource?: string;
}
