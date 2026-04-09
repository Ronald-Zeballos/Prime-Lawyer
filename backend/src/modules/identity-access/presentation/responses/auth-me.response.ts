import { AuthenticatedUserDto } from '../../application/dto/authenticated-user.dto';
import { AuthenticatedUserResponse } from './authenticated-user.response';

export class AuthMeResponse {
  user!: AuthenticatedUserResponse;

  static fromDto(dto: AuthenticatedUserDto): AuthMeResponse {
    return {
      user: AuthenticatedUserResponse.fromDto(dto),
    };
  }
}
