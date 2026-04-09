import { DomainValidationError } from '../../../../shared/domain/errors/domain-validation.error';
import { ValueObject } from '../../../../shared/domain/value-object';

export class PasswordHash extends ValueObject<string> {
  private constructor(value: string) {
    super(value);
  }

  static create(value: string): PasswordHash {
    const normalizedValue = value.trim();

    if (!normalizedValue) {
      throw new DomainValidationError('Password hash is required.');
    }

    return new PasswordHash(normalizedValue);
  }

  toString(): string {
    return this.value;
  }
}
