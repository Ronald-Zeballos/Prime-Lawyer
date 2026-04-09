import { DomainValidationError } from '../../../../shared/domain/errors/domain-validation.error';
import { ValueObject } from '../../../../shared/domain/value-object';

export class FileHash extends ValueObject<string> {
  private constructor(value: string) {
    super(value);
  }

  static create(value: string): FileHash {
    const normalizedValue = value.trim();

    if (!normalizedValue) {
      throw new DomainValidationError('File hash is required.');
    }

    return new FileHash(normalizedValue);
  }

  toString(): string {
    return this.value;
  }
}
