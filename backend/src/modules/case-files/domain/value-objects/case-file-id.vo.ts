import { DomainValidationError } from '../../../../shared/domain/errors/domain-validation.error';
import { ValueObject } from '../../../../shared/domain/value-object';

export class CaseFileId extends ValueObject<string> {
  private constructor(value: string) {
    super(value);
  }

  static create(value: string): CaseFileId {
    const normalizedValue = value.trim();

    if (!normalizedValue) {
      throw new DomainValidationError('Case file id is required.');
    }

    return new CaseFileId(normalizedValue);
  }

  toString(): string {
    return this.value;
  }
}
