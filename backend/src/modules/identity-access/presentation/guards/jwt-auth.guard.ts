import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Inject,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { Request } from 'express';
import { AccessTokenPayloadDto } from '../../application/dto/access-token-payload.dto';
import { AuthenticatedUserDto } from '../../application/dto/authenticated-user.dto';
import {
  USER_REPOSITORY,
  UserRepository,
} from '../../domain/repositories/user.repository';
import { UserId } from '../../domain/value-objects/user-id.vo';

@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
    @Inject(USER_REPOSITORY)
    private readonly userRepository: UserRepository,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest<
      Request & {
        user?: AuthenticatedUserDto;
      }
    >();
    const token = this.extractToken(request);

    if (!token) {
      throw new UnauthorizedException('Authentication token is missing.');
    }

    let payload: AccessTokenPayloadDto;

    try {
      payload = await this.jwtService.verifyAsync<AccessTokenPayloadDto>(token, {
        issuer: this.configService.getOrThrow<string>('auth.issuer'),
      });
    } catch {
      throw new UnauthorizedException('Invalid authentication token.');
    }

    const user = await this.userRepository.findById(UserId.create(payload.sub));

    if (!user) {
      throw new UnauthorizedException('Authenticated user was not found.');
    }

    if (!user.isActive) {
      throw new ForbiddenException('User is inactive.');
    }

    request.user = {
      id: user.id.value,
      email: user.email.value,
      displayName: user.displayName,
      firstName: user.firstName,
      lastName: user.lastName,
      bio: user.bio,
      role: user.role.code,
      type: user.type,
      plan: user.plan,
      tokensAvailable: user.tokensAvailable,
      isActive: user.isActive,
    };

    return true;
  }

  private extractToken(request: Request): string | null {
    const authorizationHeader = request.headers.authorization;

    if (!authorizationHeader) {
      return null;
    }

    const [scheme, token] = authorizationHeader.split(' ');

    if (scheme !== 'Bearer' || !token) {
      return null;
    }

    return token;
  }
}
