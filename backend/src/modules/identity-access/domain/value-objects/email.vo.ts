import { DomainValidationError } from '../../../../shared/domain/errors/domain-validation.error';
import { ValueObject } from '../../../../shared/domain/value-object';

export class Email extends ValueObject<string> {
  private constructor(value: string) {
    super(value);
  }

  static create(value: string): Email {
    const normalizedValue = value.trim().toLowerCase();
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    if (!emailRegex.test(normalizedValue)) {
      throw new DomainValidationError('Email format is invalid.');
    }

    return new Email(normalizedValue);
  }

  toString(): string {
    return this.value;
  }
}
