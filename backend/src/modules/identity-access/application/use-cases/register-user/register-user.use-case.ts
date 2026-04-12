import { randomUUID } from 'node:crypto';
import { Inject, Injectable } from '@nestjs/common';
import { ConflictError } from '../../../../../shared/application/errors/conflict.error';
import { ForbiddenError } from '../../../../../shared/application/errors/forbidden.error';
import { UseCase } from '../../../../../shared/application/use-case';
import { AuditEntityType } from '../../../../audit-traceability/domain/entities/audit-log.entity';
import { RegisterAuditEventUseCase } from '../../../../audit-traceability/application/use-cases/register-audit-event/register-audit-event.use-case';
import { RoleCode, RoleEntity } from '../../../domain/entities/role.entity';
import { PlanType, UserEntity, UserType } from '../../../domain/entities/user.entity';
import { USER_REPOSITORY, UserRepository } from '../../../domain/repositories/user.repository';
import { PASSWORD_HASHER_SERVICE, PasswordHasherService } from '../../../domain/services/password-hasher.service';
import { Email } from '../../../domain/value-objects/email.vo';
import { AuthenticatedUserDto } from '../../dto/authenticated-user.dto';
import { RegisterUserResultDto } from '../../dto/register-user-result.dto';
import { ACCESS_TOKEN_ISSUER, AccessTokenIssuer } from '../sign-in/sign-in.access-token-issuer';

export type RegisterUserCommand = {
  email: string;
  password: string;
  displayName?: string;
  firstName: string;
  lastName: string;
  type: UserType;
};

@Injectable()
export class RegisterUserUseCase implements UseCase<RegisterUserCommand, RegisterUserResultDto> {
  constructor(
    @Inject(USER_REPOSITORY)
    private readonly userRepository: UserRepository,
    @Inject(PASSWORD_HASHER_SERVICE)
    private readonly passwordHasher: PasswordHasherService,
    @Inject(ACCESS_TOKEN_ISSUER)
    private readonly accessTokenIssuer: AccessTokenIssuer,
    private readonly registerAuditEventUseCase: RegisterAuditEventUseCase,
  ) {}

  async execute(command: RegisterUserCommand): Promise<RegisterUserResultDto> {
    const email = Email.create(command.email);
    const existingUser = await this.userRepository.findByEmail(email);

    if (existingUser) {
      throw new ConflictError('An account with this email already exists.');
    }

    const userType = command.type;

    if (userType === UserType.ADMIN) {
      throw new ForbiddenError('Administrator accounts cannot be self-registered.');
    }

    const passwordHash = await this.passwordHasher.hash(command.password);
    const user = UserEntity.create({
      id: randomUUID(),
      email: email.value,
      passwordHash: passwordHash.value,
      displayName: command.displayName,
      firstName: command.firstName,
      lastName: command.lastName,
      bio: null,
      role: this.buildRole(userType),
      type: userType,
      plan: this.buildPlan(userType),
      tokensAvailable: this.buildInitialTokenBalance(userType),
      isActive: true,
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    const createdUser = await this.userRepository.create(user);
    const authenticatedUser = this.toAuthenticatedUser(createdUser);
    const accessToken = await this.accessTokenIssuer.issue({
      sub: authenticatedUser.id,
      email: authenticatedUser.email,
      role: authenticatedUser.role,
      type: authenticatedUser.type,
      plan: authenticatedUser.plan,
    });

    await this.registerAuditEventUseCase.execute({
      entityType: AuditEntityType.AUTH,
      entityId: createdUser.id.value,
      action: 'REGISTER',
      performedById: createdUser.id.value,
      metadata: {
        email: createdUser.email.value,
        type: createdUser.type,
        plan: createdUser.plan,
      },
    });

    return {
      accessToken,
      user: authenticatedUser,
    };
  }

  private buildRole(userType: UserType): RoleEntity {
    switch (userType) {
      case UserType.NATURAL:
        return new RoleEntity('role-natural', RoleCode.NATURAL, 'Natural User');
      case UserType.LAWYER:
        return new RoleEntity('role-lawyer', RoleCode.LAWYER, 'Lawyer');
      case UserType.ADMIN:
        return new RoleEntity('role-admin', RoleCode.ADMIN, 'Administrator');
    }
  }

  private buildPlan(userType: UserType): PlanType {
    switch (userType) {
      case UserType.NATURAL:
        return PlanType.FREE;
      case UserType.LAWYER:
        return PlanType.FREE;
      case UserType.ADMIN:
        return PlanType.ADMIN;
    }
  }

  private buildInitialTokenBalance(userType: UserType): number {
    switch (userType) {
      case UserType.NATURAL:
        return 10;
      case UserType.LAWYER:
        return 25;
      case UserType.ADMIN:
        return 1000;
    }
  }

  private toAuthenticatedUser(user: UserEntity): AuthenticatedUserDto {
    return {
      id: user.id.value,
      email: user.email.value,
      displayName: user.displayName,
      firstName: user.firstName,
      lastName: user.lastName,
      bio: user.bio,
      role: user.role.code,
      type: user.type,
      plan: user.plan,
      tokensAvailable: user.tokensAvailable,
      isActive: user.isActive,
    };
  }
}
