import { AccessTokenPayloadDto } from '../../dto/access-token-payload.dto';

export const ACCESS_TOKEN_ISSUER = Symbol('ACCESS_TOKEN_ISSUER');

export interface AccessTokenIssuer {
  issue(payload: AccessTokenPayloadDto): Promise<string>;
}
