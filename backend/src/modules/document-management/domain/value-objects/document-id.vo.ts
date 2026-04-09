import { DomainValidationError } from '../../../../shared/domain/errors/domain-validation.error';
import { ValueObject } from '../../../../shared/domain/value-object';

export class DocumentId extends ValueObject<string> {
  private constructor(value: string) {
    super(value);
  }

  static create(value: string): DocumentId {
    const normalizedValue = value.trim();

    if (!normalizedValue) {
      throw new DomainValidationError('Document id is required.');
    }

    return new DocumentId(normalizedValue);
  }

  toString(): string {
    return this.value;
  }
}
