import { PasswordHash } from '../value-objects/password-hash.vo';

export const PASSWORD_HASHER_SERVICE = Symbol('PASSWORD_HASHER_SERVICE');

export interface PasswordHasherService {
  hash(plainTextPassword: string): Promise<PasswordHash>;
  verify(plainTextPassword: string, passwordHash: PasswordHash): Promise<boolean>;
}
