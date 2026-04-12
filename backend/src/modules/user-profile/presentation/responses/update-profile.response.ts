import { AuthenticatedUserResponse } from '../../../identity-access/presentation/responses/authenticated-user.response';
import { ProfileDto } from '../../application/dto/profile.dto';

export class UpdateProfileResponse {
  user!: AuthenticatedUserResponse;

  static fromDto(dto: ProfileDto): UpdateProfileResponse {
    return {
      user: AuthenticatedUserResponse.fromDto(dto),
    };
  }
}
