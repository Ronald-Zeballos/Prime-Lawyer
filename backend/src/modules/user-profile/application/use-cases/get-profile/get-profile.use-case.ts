import { Inject, Injectable } from '@nestjs/common';
import { ForbiddenError } from '../../../../../shared/application/errors/forbidden.error';
import { NotFoundError } from '../../../../../shared/application/errors/not-found.error';
import { UseCase } from '../../../../../shared/application/use-case';
import {
  USER_REPOSITORY,
  UserRepository,
} from '../../../../identity-access/domain/repositories/user.repository';
import { UserId } from '../../../../identity-access/domain/value-objects/user-id.vo';
import { ProfileDto } from '../../dto/profile.dto';

export type GetProfileQuery = {
  userId: string;
};

@Injectable()
export class GetProfileUseCase implements UseCase<GetProfileQuery, ProfileDto> {
  constructor(
    @Inject(USER_REPOSITORY)
    private readonly userRepository: UserRepository,
  ) {}

  async execute(query: GetProfileQuery): Promise<ProfileDto> {
    const user = await this.userRepository.findById(UserId.create(query.userId));

    if (!user) {
      throw new NotFoundError('Profile was not found.');
    }

    if (!user.isActive) {
      throw new ForbiddenError('User is inactive.');
    }

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
