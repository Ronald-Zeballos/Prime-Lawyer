import { DomainValidationError } from '../../../../shared/domain/errors/domain-validation.error';
import { ValueObject } from '../../../../shared/domain/value-object';

export class MimeType extends ValueObject<string> {
  private constructor(value: string) {
    super(value);
  }

  static create(value: string): MimeType {
    const normalizedValue = value.trim().toLowerCase();

    if (!normalizedValue) {
      throw new DomainValidationError('File type is required.');
    }

    return new MimeType(normalizedValue);
  }

  toString(): string {
    return this.value;
  }
}
