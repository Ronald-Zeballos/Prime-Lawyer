import { AuthenticatedUserDto } from './authenticated-user.dto';

export type SignInResultDto = {
  accessToken: string;
  user: AuthenticatedUserDto;
};
