import { AggregateRoot } from '../../../../shared/domain/aggregate-root';
import { PasswordHash } from '../value-objects/password-hash.vo';
import { UserId } from '../value-objects/user-id.vo';
import { Email } from '../value-objects/email.vo';
import { RoleEntity } from './role.entity';

type UserEntityProps = {
  email: Email;
  passwordHash: PasswordHash;
  firstName: string;
  lastName: string;
  role: RoleEntity;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
};

type CreateUserEntityProps = {
  id: string;
  email: string;
  passwordHash: string;
  firstName: string;
  lastName: string;
  role: RoleEntity;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
};

export class UserEntity extends AggregateRoot<UserId> {
  private constructor(id: UserId, private readonly props: UserEntityProps) {
    super(id);
  }

  static create(props: CreateUserEntityProps): UserEntity {
    return new UserEntity(UserId.create(props.id), {
      email: Email.create(props.email),
      passwordHash: PasswordHash.create(props.passwordHash),
      firstName: props.firstName.trim(),
      lastName: props.lastName.trim(),
      role: props.role,
      isActive: props.isActive,
      createdAt: props.createdAt,
      updatedAt: props.updatedAt,
    });
  }

  get email(): Email {
    return this.props.email;
  }

  get passwordHash(): PasswordHash {
    return this.props.passwordHash;
  }

  get firstName(): string {
    return this.props.firstName;
  }

  get lastName(): string {
    return this.props.lastName;
  }

  get role(): RoleEntity {
    return this.props.role;
  }

  get isActive(): boolean {
    return this.props.isActive;
  }

  get createdAt(): Date {
    return this.props.createdAt;
  }

  get updatedAt(): Date {
    return this.props.updatedAt;
  }
}
