import { DomainValidationError } from '../../../../shared/domain/errors/domain-validation.error';
import { ValueObject } from '../../../../shared/domain/value-object';

export class ClientId extends ValueObject<string> {
  private constructor(value: string) {
    super(value);
  }

  static create(value: string): ClientId {
    const normalizedValue = value.trim();

    if (!normalizedValue) {
      throw new DomainValidationError('Client id is required.');
    }

    return new ClientId(normalizedValue);
  }

  toString(): string {
    return this.value;
  }
}
