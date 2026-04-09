import { DomainValidationError } from '../../../../shared/domain/errors/domain-validation.error';
import { ValueObject } from '../../../../shared/domain/value-object';

export enum ConfidentialityLevel {
  STANDARD = 'STANDARD',
  CONFIDENTIAL = 'CONFIDENTIAL',
  HIGHLY_CONFIDENTIAL = 'HIGHLY_CONFIDENTIAL',
}

export class ConfidentialityLevelValue extends ValueObject<ConfidentialityLevel> {
  private constructor(value: ConfidentialityLevel) {
    super(value);
  }

  static create(value: string): ConfidentialityLevelValue {
    const normalizedValue =
      value.trim().toUpperCase() as ConfidentialityLevel;

    if (!Object.values(ConfidentialityLevel).includes(normalizedValue)) {
      throw new DomainValidationError('Confidentiality level is invalid.');
    }

    return new ConfidentialityLevelValue(normalizedValue);
  }
}
