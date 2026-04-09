import { IsOptional, IsString, MaxLength } from 'class-validator';

export class SearchClientsRequest {
  @IsOptional()
  @IsString()
  @MaxLength(100)
  term?: string;
}
