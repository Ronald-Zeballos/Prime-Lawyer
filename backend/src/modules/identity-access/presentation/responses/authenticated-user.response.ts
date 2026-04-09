import { AuthenticatedUserDto } from '../../application/dto/authenticated-user.dto';
import { RoleCode } from '../../domain/entities/role.entity';

export class AuthenticatedUserResponse {
  id!: string;
  email!: string;
  firstName!: string;
  lastName!: string;
  role!: RoleCode;

  static fromDto(dto: AuthenticatedUserDto): AuthenticatedUserResponse {
    return {
      id: dto.id,
      email: dto.email,
      firstName: dto.firstName,
      lastName: dto.lastName,
      role: dto.role,
    };
  }
}
