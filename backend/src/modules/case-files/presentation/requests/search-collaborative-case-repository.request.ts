import { IsOptional, IsString, MaxLength } from 'class-validator';

export class SearchCollaborativeCaseRepositoryRequest {
  @IsOptional()
  @IsString()
  @MaxLength(100)
  term?: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  processType?: string;
}
