import { AuthenticatedUserDto } from './authenticated-user.dto';

export type RegisterUserResultDto = {
  accessToken: string;
  user: AuthenticatedUserDto;
};
