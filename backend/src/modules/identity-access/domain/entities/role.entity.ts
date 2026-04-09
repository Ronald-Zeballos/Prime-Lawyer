import { BaseEntity } from '../../../../shared/domain/base-entity';

export enum RoleCode {
  ADMIN = 'ADMIN',
  LAWYER = 'LAWYER',
}

export class RoleEntity extends BaseEntity<string> {
  constructor(
    id: string,
    public readonly code: RoleCode,
    public readonly name: string,
  ) {
    super(id);
  }
}
