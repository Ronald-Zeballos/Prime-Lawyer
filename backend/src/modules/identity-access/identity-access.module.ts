import { Module } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtModule } from '@nestjs/jwt';
import { AuthController } from './presentation/controllers/auth.controller';
import { SignInUseCase } from './application/use-cases/sign-in/sign-in.use-case';
import { GetAuthenticatedUserUseCase } from './application/use-cases/get-authenticated-user/get-authenticated-user.use-case';
import { RegisterUserUseCase } from './application/use-cases/register-user/register-user.use-case';
import {
  ACCESS_TOKEN_ISSUER,
} from './application/use-cases/sign-in/sign-in.access-token-issuer';
import {
  PASSWORD_HASHER_SERVICE,
} from './domain/services/password-hasher.service';
import { USER_REPOSITORY } from './domain/repositories/user.repository';
import { PrismaUserRepository } from './infrastructure/persistence/repositories/prisma-user.repository';
import { ScryptPasswordHasherService } from './infrastructure/services/scrypt-password-hasher.service';
import { JwtAccessTokenIssuer } from './infrastructure/services/jwt-access-token-issuer.service';
import { JwtAuthGuard } from './presentation/guards/jwt-auth.guard';

@Module({
  imports: [
    JwtModule.registerAsync({
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        secret: configService.getOrThrow<string>('auth.jwtSecret'),
      }),
    }),
  ],
  controllers: [AuthController],
  providers: [
    RegisterUserUseCase,
    SignInUseCase,
    GetAuthenticatedUserUseCase,
    JwtAuthGuard,
    {
      provide: USER_REPOSITORY,
      useClass: PrismaUserRepository,
    },
    {
      provide: PASSWORD_HASHER_SERVICE,
      useClass: ScryptPasswordHasherService,
    },
    {
      provide: ACCESS_TOKEN_ISSUER,
      useClass: JwtAccessTokenIssuer,
    },
  ],
  exports: [JwtModule, JwtAuthGuard, USER_REPOSITORY],
})
export class IdentityAccessModule {}
