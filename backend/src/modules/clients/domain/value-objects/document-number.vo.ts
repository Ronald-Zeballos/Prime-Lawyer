import { DomainValidationError } from '../../../../shared/domain/errors/domain-validation.error';
import { ValueObject } from '../../../../shared/domain/value-object';

export class DocumentNumber extends ValueObject<string> {
  private constructor(value: string) {
    super(value);
  }

  static create(value: string): DocumentNumber {
    const normalizedValue = value.trim();

    if (!normalizedValue) {
      throw new DomainValidationError('Document number is required.');
    }

    return new DocumentNumber(normalizedValue);
  }

  toString(): string {
    return this.value;
  }
}
