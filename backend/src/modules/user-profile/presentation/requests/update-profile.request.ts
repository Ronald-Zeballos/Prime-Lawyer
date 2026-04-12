import { IsOptional, IsString, MaxLength, MinLength } from 'class-validator';

export class UpdateProfileRequest {
  @IsOptional()
  @IsString()
  @MaxLength(120)
  displayName?: string;

  @IsOptional()
  @IsString()
  @MinLength(2)
  @MaxLength(120)
  firstName?: string;

  @IsOptional()
  @IsString()
  @MinLength(2)
  @MaxLength(120)
  lastName?: string;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  bio?: string | null;
}
