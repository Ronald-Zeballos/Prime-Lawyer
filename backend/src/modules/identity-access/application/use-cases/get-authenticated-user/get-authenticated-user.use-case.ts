import { Inject, Injectable } from '@nestjs/common';
import { ForbiddenError } from '../../../../../shared/application/errors/forbidden.error';
import { NotFoundError } from '../../../../../shared/application/errors/not-found.error';
import { UseCase } from '../../../../../shared/application/use-case';
import {
  USER_REPOSITORY,
  UserRepository,
} from '../../../domain/repositories/user.repository';
import { UserId } from '../../../domain/value-objects/user-id.vo';
import { AuthenticatedUserDto } from '../../dto/authenticated-user.dto';

export type GetAuthenticatedUserQuery = {
  userId: string;
};

@Injectable()
export class GetAuthenticatedUserUseCase
  implements UseCase<GetAuthenticatedUserQuery, AuthenticatedUserDto>
{
  constructor(
    @Inject(USER_REPOSITORY)
    private readonly userRepository: UserRepository,
  ) {}

  async execute(query: GetAuthenticatedUserQuery): Promise<AuthenticatedUserDto> {
    const user = await this.userRepository.findById(UserId.create(query.userId));

    if (!user) {
      throw new NotFoundError('Authenticated user was not found.');
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
