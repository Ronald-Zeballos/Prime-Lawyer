import { Inject, Injectable } from '@nestjs/common';
import { ForbiddenError } from '../../../../../shared/application/errors/forbidden.error';
import { NotFoundError } from '../../../../../shared/application/errors/not-found.error';
import { UseCase } from '../../../../../shared/application/use-case';
import { RegisterAuditEventUseCase } from '../../../../audit-traceability/application/use-cases/register-audit-event/register-audit-event.use-case';
import { AuditEntityType } from '../../../../audit-traceability/domain/entities/audit-log.entity';
import {
  USER_REPOSITORY,
  UserRepository,
} from '../../../../identity-access/domain/repositories/user.repository';
import { UserId } from '../../../../identity-access/domain/value-objects/user-id.vo';
import { ProfileDto } from '../../dto/profile.dto';

export type UpdateProfileCommand = {
  userId: string;
  displayName?: string;
  firstName?: string;
  lastName?: string;
  bio?: string | null;
};

@Injectable()
export class UpdateProfileUseCase
  implements UseCase<UpdateProfileCommand, ProfileDto>
{
  constructor(
    @Inject(USER_REPOSITORY)
    private readonly userRepository: UserRepository,
    private readonly registerAuditEventUseCase: RegisterAuditEventUseCase,
  ) {}

  async execute(command: UpdateProfileCommand): Promise<ProfileDto> {
    const user = await this.userRepository.findById(UserId.create(command.userId));

    if (!user) {
      throw new NotFoundError('Profile was not found.');
    }

    if (!user.isActive) {
      throw new ForbiddenError('User is inactive.');
    }

    const previousProfile = {
      displayName: user.displayName,
      firstName: user.firstName,
      lastName: user.lastName,
      bio: user.bio,
    };

    user.updateProfile({
      displayName: command.displayName,
      firstName: command.firstName,
      lastName: command.lastName,
      bio: command.bio,
      updatedAt: new Date(),
    });

    const updatedUser = await this.userRepository.updateProfile(user);

    await this.registerAuditEventUseCase.execute({
      entityType: AuditEntityType.USER_PROFILE,
      entityId: updatedUser.id.value,
      action: 'UPDATE_PROFILE',
      performedById: updatedUser.id.value,
      metadata: {
        previous: previousProfile,
        current: {
          displayName: updatedUser.displayName,
          firstName: updatedUser.firstName,
          lastName: updatedUser.lastName,
          bio: updatedUser.bio,
        },
      },
    });

    return {
      id: updatedUser.id.value,
      email: updatedUser.email.value,
      displayName: updatedUser.displayName,
      firstName: updatedUser.firstName,
      lastName: updatedUser.lastName,
      bio: updatedUser.bio,
      role: updatedUser.role.code,
      type: updatedUser.type,
      plan: updatedUser.plan,
      tokensAvailable: updatedUser.tokensAvailable,
      isActive: updatedUser.isActive,
    };
  }
}
