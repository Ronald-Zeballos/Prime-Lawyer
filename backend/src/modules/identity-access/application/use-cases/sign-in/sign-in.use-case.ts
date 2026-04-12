import { Inject, Injectable } from '@nestjs/common';
import { ForbiddenError } from '../../../../../shared/application/errors/forbidden.error';
import { UnauthorizedError } from '../../../../../shared/application/errors/unauthorized.error';
import { UseCase } from '../../../../../shared/application/use-case';
import {
  AuditEntityType,
} from '../../../../audit-traceability/domain/entities/audit-log.entity';
import { RegisterAuditEventUseCase } from '../../../../audit-traceability/application/use-cases/register-audit-event/register-audit-event.use-case';
import { UserEntity } from '../../../domain/entities/user.entity';
import {
  USER_REPOSITORY,
  UserRepository,
} from '../../../domain/repositories/user.repository';
import {
  PASSWORD_HASHER_SERVICE,
  PasswordHasherService,
} from '../../../domain/services/password-hasher.service';
import { Email } from '../../../domain/value-objects/email.vo';
import { AuthenticatedUserDto } from '../../dto/authenticated-user.dto';
import { SignInResultDto } from '../../dto/sign-in-result.dto';
import {
  ACCESS_TOKEN_ISSUER,
  AccessTokenIssuer,
} from './sign-in.access-token-issuer';

export type SignInCommand = {
  email: string;
  password: string;
};

@Injectable()
export class SignInUseCase
  implements UseCase<SignInCommand, SignInResultDto>
{
  constructor(
    @Inject(USER_REPOSITORY)
    private readonly userRepository: UserRepository,
    @Inject(PASSWORD_HASHER_SERVICE)
    private readonly passwordHasher: PasswordHasherService,
    @Inject(ACCESS_TOKEN_ISSUER)
    private readonly accessTokenIssuer: AccessTokenIssuer,
    private readonly registerAuditEventUseCase: RegisterAuditEventUseCase,
  ) {}

  async execute(command: SignInCommand): Promise<SignInResultDto> {
    const email = Email.create(command.email);
    const user = await this.userRepository.findByEmail(email);

    if (!user) {
      throw new UnauthorizedError('Invalid credentials.');
    }

    if (!user.isActive) {
      throw new ForbiddenError('User is inactive.');
    }

    const isPasswordValid = await this.passwordHasher.verify(
      command.password,
      user.passwordHash,
    );

    if (!isPasswordValid) {
      throw new UnauthorizedError('Invalid credentials.');
    }

    const authenticatedUser = this.toAuthenticatedUser(user);
    const accessToken = await this.accessTokenIssuer.issue({
      sub: authenticatedUser.id,
      email: authenticatedUser.email,
      role: authenticatedUser.role,
      type: authenticatedUser.type,
      plan: authenticatedUser.plan,
    });

    await this.registerAuditEventUseCase.execute({
      entityType: AuditEntityType.AUTH,
      entityId: authenticatedUser.id,
      action: 'LOGIN',
      performedById: authenticatedUser.id,
      metadata: {
        email: authenticatedUser.email,
        role: authenticatedUser.role,
        type: authenticatedUser.type,
        plan: authenticatedUser.plan,
      },
    });

    return {
      accessToken,
      user: authenticatedUser,
    };
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
