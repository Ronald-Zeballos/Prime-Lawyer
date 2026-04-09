import { RoleCode } from '../../domain/entities/role.entity';

export type AccessTokenPayloadDto = {
  sub: string;
  email: string;
  role: RoleCode;
};
