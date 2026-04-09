import { DomainValidationError } from '../../../../shared/domain/errors/domain-validation.error';
import { ValueObject } from '../../../../shared/domain/value-object';

export enum CaseStatus {
  OPEN = 'OPEN',
  IN_PROGRESS = 'IN_PROGRESS',
  CLOSED = 'CLOSED',
  ARCHIVED = 'ARCHIVED',
}

export class CaseStatusValue extends ValueObject<CaseStatus> {
  private constructor(value: CaseStatus) {
    super(value);
  }

  static create(value: string): CaseStatusValue {
    const normalizedValue = value.trim().toUpperCase() as CaseStatus;

    if (!Object.values(CaseStatus).includes(normalizedValue)) {
      throw new DomainValidationError('Case status is invalid.');
    }

    return new CaseStatusValue(normalizedValue);
  }
}
