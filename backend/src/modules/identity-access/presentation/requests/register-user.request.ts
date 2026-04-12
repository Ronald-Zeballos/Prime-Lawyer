import { IsEmail, IsEnum, IsOptional, IsString, MinLength } from 'class-validator';
import { UserType } from '../../domain/entities/user.entity';

export class RegisterUserRequest {
  @IsEmail()
  email!: string;

  @IsString()
  @MinLength(8)
  password!: string;

  @IsOptional()
  @IsString()
  @MinLength(3)
  displayName?: string;

  @IsString()
  @MinLength(2)
  firstName!: string;

  @IsString()
  @MinLength(2)
  lastName!: string;

  @IsEnum(UserType)
  type!: UserType;
}
