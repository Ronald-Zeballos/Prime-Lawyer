import { RoleCode } from '../../domain/entities/role.entity';
import { PlanType, UserType } from '../../domain/entities/user.entity';

export type AuthenticatedUserDto = {
  id: string;
  email: string;
  displayName: string;
  firstName: string;
  lastName: string;
  bio: string | null;
  role: RoleCode;
  type: UserType;
  plan: PlanType;
  tokensAvailable: number;
  isActive: boolean;
};
