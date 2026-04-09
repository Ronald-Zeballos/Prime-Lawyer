import { RoleCode } from '../../domain/entities/role.entity';

export type AuthenticatedUserDto = {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  role: RoleCode;
};
