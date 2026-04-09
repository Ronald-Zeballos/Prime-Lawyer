import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { AccessTokenPayloadDto } from '../../application/dto/access-token-payload.dto';
import { AccessTokenIssuer } from '../../application/use-cases/sign-in/sign-in.access-token-issuer';

@Injectable()
export class JwtAccessTokenIssuer implements AccessTokenIssuer {
  constructor(
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  async issue(payload: AccessTokenPayloadDto): Promise<string> {
    return this.jwtService.signAsync(payload, {
      expiresIn: this.configService.getOrThrow<string>('auth.jwtExpiresIn') as never,
      issuer: this.configService.getOrThrow<string>('auth.issuer'),
    });
  }
}
