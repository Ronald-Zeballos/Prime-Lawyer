import { DomainValidationError } from '../../../../shared/domain/errors/domain-validation.error';
import { ValueObject } from '../../../../shared/domain/value-object';

export class UserId extends ValueObject<string> {
  private constructor(value: string) {
    super(value);
  }

  static create(value: string): UserId {
    const normalizedValue = value.trim();

    if (!normalizedValue) {
      throw new DomainValidationError('User id is required.');
    }

    return new UserId(normalizedValue);
  }

  toString(): string {
    return this.value;
  }
}
