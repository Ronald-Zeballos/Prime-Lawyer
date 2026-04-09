import { SignInResultDto } from '../../application/dto/sign-in-result.dto';
import { AuthenticatedUserResponse } from './authenticated-user.response';

export class SignInResponse {
  accessToken!: string;
  user!: AuthenticatedUserResponse;

  static fromDto(dto: SignInResultDto): SignInResponse {
    return {
      accessToken: dto.accessToken,
      user: AuthenticatedUserResponse.fromDto(dto.user),
    };
  }
}
