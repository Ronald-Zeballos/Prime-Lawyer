import { Body, Controller, Get, Patch, Req, UseGuards } from '@nestjs/common';
import { Request } from 'express';
import { AuthenticatedUserDto } from '../../../identity-access/application/dto/authenticated-user.dto';
import { JwtAuthGuard } from '../../../identity-access/presentation/guards/jwt-auth.guard';
import { GetProfileUseCase } from '../../application/use-cases/get-profile/get-profile.use-case';
import { UpdateProfileUseCase } from '../../application/use-cases/update-profile/update-profile.use-case';
import { UpdateProfileRequest } from '../requests/update-profile.request';
import { ProfileMeResponse } from '../responses/profile-me.response';
import { UpdateProfileResponse } from '../responses/update-profile.response';

@Controller('profile')
@UseGuards(JwtAuthGuard)
export class ProfileController {
  constructor(
    private readonly getProfileUseCase: GetProfileUseCase,
    private readonly updateProfileUseCase: UpdateProfileUseCase,
  ) {}

  @Get('me')
  async me(
    @Req() request: Request & { user: AuthenticatedUserDto },
  ): Promise<ProfileMeResponse> {
    const user = await this.getProfileUseCase.execute({
      userId: request.user.id,
    });

    return ProfileMeResponse.fromDto(user);
  }

  @Patch('me')
  async update(
    @Req() request: Request & { user: AuthenticatedUserDto },
    @Body() body: UpdateProfileRequest,
  ): Promise<UpdateProfileResponse> {
    const user = await this.updateProfileUseCase.execute({
      userId: request.user.id,
      displayName: body.displayName,
      firstName: body.firstName,
      lastName: body.lastName,
      bio: body.bio,
    });

    return UpdateProfileResponse.fromDto(user);
  }
}
