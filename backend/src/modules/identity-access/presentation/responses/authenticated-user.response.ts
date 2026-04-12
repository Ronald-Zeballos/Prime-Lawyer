import { AuthenticatedUserDto } from '../../application/dto/authenticated-user.dto';
import { RoleCode } from '../../domain/entities/role.entity';
import { PlanType, UserType } from '../../domain/entities/user.entity';

export class AuthenticatedUserResponse {
  id!: string;
  email!: string;
  displayName!: string;
  firstName!: string;
  lastName!: string;
  bio!: string | null;
  role!: RoleCode;
  type!: UserType;
  plan!: PlanType;
  tokensAvailable!: number;
  isActive!: boolean;

  static fromDto(dto: AuthenticatedUserDto): AuthenticatedUserResponse {
    return {
      id: dto.id,
      email: dto.email,
      displayName: dto.displayName,
      firstName: dto.firstName,
      lastName: dto.lastName,
      bio: dto.bio,
      role: dto.role,
      type: dto.type,
      plan: dto.plan,
      tokensAvailable: dto.tokensAvailable,
      isActive: dto.isActive,
    };
  }
}
