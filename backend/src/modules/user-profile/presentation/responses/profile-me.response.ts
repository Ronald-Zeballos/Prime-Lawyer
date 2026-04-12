import { AuthenticatedUserResponse } from '../../../identity-access/presentation/responses/authenticated-user.response';
import { ProfileDto } from '../../application/dto/profile.dto';

export class ProfileMeResponse {
  user!: AuthenticatedUserResponse;

  static fromDto(dto: ProfileDto): ProfileMeResponse {
    return {
      user: AuthenticatedUserResponse.fromDto(dto),
    };
  }
}
