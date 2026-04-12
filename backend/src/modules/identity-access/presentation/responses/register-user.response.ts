import { RegisterUserResultDto } from '../../application/dto/register-user-result.dto';
import { AuthenticatedUserResponse } from './authenticated-user.response';

export class RegisterUserResponse {
  accessToken!: string;
  user!: AuthenticatedUserResponse;

  static fromDto(dto: RegisterUserResultDto): RegisterUserResponse {
    return {
      accessToken: dto.accessToken,
      user: AuthenticatedUserResponse.fromDto(dto.user),
    };
  }
}
