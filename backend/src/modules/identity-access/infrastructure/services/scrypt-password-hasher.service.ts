import { Injectable } from '@nestjs/common';
import { randomBytes, scryptSync, timingSafeEqual } from 'node:crypto';
import { PasswordHasherService } from '../../domain/services/password-hasher.service';
import { PasswordHash } from '../../domain/value-objects/password-hash.vo';

@Injectable()
export class ScryptPasswordHasherService implements PasswordHasherService {
  async hash(plainTextPassword: string): Promise<PasswordHash> {
    const salt = randomBytes(16).toString('hex');
    const derivedKey = scryptSync(plainTextPassword, salt, 64).toString('hex');

    return PasswordHash.create(`scrypt:${salt}:${derivedKey}`);
  }

  async verify(
    plainTextPassword: string,
    passwordHash: PasswordHash,
  ): Promise<boolean> {
    const [algorithm, salt, storedHash] = passwordHash.value.split(':');

    if (algorithm !== 'scrypt' || !salt || !storedHash) {
      return false;
    }

    const derivedKey = scryptSync(plainTextPassword, salt, 64).toString('hex');

    return timingSafeEqual(
      Buffer.from(derivedKey, 'hex'),
      Buffer.from(storedHash, 'hex'),
    );
  }
}
