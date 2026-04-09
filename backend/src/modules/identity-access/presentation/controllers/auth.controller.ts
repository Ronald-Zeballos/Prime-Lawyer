import {
  Body,
  Controller,
  Get,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';
import { Request } from 'express';
import { GetAuthenticatedUserUseCase } from '../../application/use-cases/get-authenticated-user/get-authenticated-user.use-case';
import { SignInUseCase } from '../../application/use-cases/sign-in/sign-in.use-case';
import { AuthenticatedUserDto } from '../../application/dto/authenticated-user.dto';
import { SignInRequest } from '../requests/sign-in.request';
import { AuthMeResponse } from '../responses/auth-me.response';
import { SignInResponse } from '../responses/sign-in.response';
import { JwtAuthGuard } from '../guards/jwt-auth.guard';

@Controller('auth')
export class AuthController {
  constructor(
    private readonly signInUseCase: SignInUseCase,
    private readonly getAuthenticatedUserUseCase: GetAuthenticatedUserUseCase,
  ) {}

  @Post('login')
  async signIn(@Body() request: SignInRequest): Promise<SignInResponse> {
    const result = await this.signInUseCase.execute({
      email: request.email,
      password: request.password,
    });

    return SignInResponse.fromDto(result);
  }

  @Get('me')
  @UseGuards(JwtAuthGuard)
  async me(
    @Req()
    request: Request & {
      user: AuthenticatedUserDto;
    },
  ): Promise<AuthMeResponse> {
    const user = await this.getAuthenticatedUserUseCase.execute({
      userId: request.user.id,
    });

    return AuthMeResponse.fromDto(user);
  }
}
