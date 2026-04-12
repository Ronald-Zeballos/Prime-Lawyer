import { RoleCode } from '../../domain/entities/role.entity';
import { PlanType, UserType } from '../../domain/entities/user.entity';

export type AccessTokenPayloadDto = {
  sub: string;
  email: string;
  role: RoleCode;
  type: UserType;
  plan: PlanType;
};
