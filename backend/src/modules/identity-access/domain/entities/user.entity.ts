import { AggregateRoot } from '../../../../shared/domain/aggregate-root';
import { DomainValidationError } from '../../../../shared/domain/errors/domain-validation.error';
import { PasswordHash } from '../value-objects/password-hash.vo';
import { UserId } from '../value-objects/user-id.vo';
import { Email } from '../value-objects/email.vo';
import { RoleEntity } from './role.entity';

export enum UserType {
  NATURAL = 'NATURAL',
  LAWYER = 'LAWYER',
  ADMIN = 'ADMIN',
}

export enum PlanType {
  FREE = 'FREE',
  LAWYER_PRO = 'LAWYER_PRO',
  ADMIN = 'ADMIN',
}

type UserEntityProps = {
  email: Email;
  passwordHash: PasswordHash;
  displayName: string;
  firstName: string;
  lastName: string;
  bio: string | null;
  role: RoleEntity;
  type: UserType;
  plan: PlanType;
  tokensAvailable: number;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
};

type CreateUserEntityProps = {
  id: string;
  email: string;
  passwordHash: string;
  displayName?: string | null;
  firstName: string;
  lastName: string;
  bio?: string | null;
  role: RoleEntity;
  type: UserType | string;
  plan: PlanType | string;
  tokensAvailable: number;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
};

export class UserEntity extends AggregateRoot<UserId> {
  private constructor(id: UserId, private readonly props: UserEntityProps) {
    super(id);
  }

  static create(props: CreateUserEntityProps): UserEntity {
    const firstName = this.normalizeRequiredText(props.firstName, 'First name');
    const lastName = this.normalizeRequiredText(props.lastName, 'Last name');
    const displayName = this.normalizeOptionalDisplayName(props.displayName) ??
      `${firstName} ${lastName}`.trim();
    const bio = this.normalizeOptionalBio(props.bio);

    return new UserEntity(UserId.create(props.id), {
      email: Email.create(props.email),
      passwordHash: PasswordHash.create(props.passwordHash),
      displayName,
      firstName,
      lastName,
      bio,
      role: props.role,
      type: this.normalizeUserType(props.type),
      plan: this.normalizePlanType(props.plan),
      tokensAvailable: this.normalizeTokensAvailable(props.tokensAvailable),
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

  get displayName(): string {
    return this.props.displayName;
  }

  get firstName(): string {
    return this.props.firstName;
  }

  get lastName(): string {
    return this.props.lastName;
  }

  get bio(): string | null {
    return this.props.bio;
  }

  get role(): RoleEntity {
    return this.props.role;
  }

  get type(): UserType {
    return this.props.type;
  }

  get plan(): PlanType {
    return this.props.plan;
  }

  get tokensAvailable(): number {
    return this.props.tokensAvailable;
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

  updateProfile(props: {
    displayName?: string | null;
    firstName?: string;
    lastName?: string;
    bio?: string | null;
    updatedAt?: Date;
  }): void {
    const hasAnyField =
      props.displayName !== undefined ||
      props.firstName !== undefined ||
      props.lastName !== undefined ||
      props.bio !== undefined;

    if (!hasAnyField) {
      throw new DomainValidationError('At least one profile field must be provided.');
    }

    const nextFirstName =
      props.firstName !== undefined
        ? UserEntity.normalizeRequiredText(props.firstName, 'First name')
        : this.props.firstName;
    const nextLastName =
      props.lastName !== undefined
        ? UserEntity.normalizeRequiredText(props.lastName, 'Last name')
        : this.props.lastName;
    const nextDisplayName =
      props.displayName !== undefined
        ? UserEntity.normalizeOptionalDisplayName(props.displayName) ??
          `${nextFirstName} ${nextLastName}`.trim()
        : this.props.displayName;

    this.props.firstName = nextFirstName;
    this.props.lastName = nextLastName;
    this.props.displayName = nextDisplayName;

    if (props.bio !== undefined) {
      this.props.bio = UserEntity.normalizeOptionalBio(props.bio);
    }

    this.props.updatedAt = props.updatedAt ?? new Date();
  }

  private static normalizeUserType(value: UserType | string): UserType {
    const normalizedValue = this.normalizeRequiredText(value, 'User type').toUpperCase();

    if (!Object.values(UserType).includes(normalizedValue as UserType)) {
      throw new DomainValidationError('User type is invalid.');
    }

    return normalizedValue as UserType;
  }

  private static normalizePlanType(value: PlanType | string): PlanType {
    const normalizedValue = this.normalizeRequiredText(value, 'Plan type').toUpperCase();

    if (!Object.values(PlanType).includes(normalizedValue as PlanType)) {
      throw new DomainValidationError('Plan type is invalid.');
    }

    return normalizedValue as PlanType;
  }

  private static normalizeTokensAvailable(value: number): number {
    if (!Number.isInteger(value) || value < 0) {
      throw new DomainValidationError('Tokens available must be a non-negative integer.');
    }

    return value;
  }

  private static normalizeRequiredText(value: string, fieldName: string): string {
    const normalizedValue = value.trim();

    if (!normalizedValue) {
      throw new DomainValidationError(`${fieldName} is required.`);
    }

    return normalizedValue;
  }

  private static normalizeOptionalDisplayName(value?: string | null): string | null {
    if (value === undefined || value === null) {
      return null;
    }

    const normalizedValue = value.trim();

    return normalizedValue ? normalizedValue : null;
  }

  private static normalizeOptionalBio(value?: string | null): string | null {
    if (value === undefined || value === null) {
      return null;
    }

    const normalizedValue = value.trim();

    if (!normalizedValue) {
      return null;
    }

    if (normalizedValue.length > 500) {
      throw new DomainValidationError('Bio cannot exceed 500 characters.');
    }

    return normalizedValue;
  }
}
