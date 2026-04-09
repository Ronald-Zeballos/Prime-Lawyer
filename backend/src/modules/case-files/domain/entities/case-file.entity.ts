import { BaseEntity } from '../../../../shared/domain/base-entity';
import { DomainValidationError } from '../../../../shared/domain/errors/domain-validation.error';
import { CaseFileId } from '../value-objects/case-file-id.vo';
import { CaseStatus, CaseStatusValue } from '../value-objects/case-status.vo';
import {
  ConfidentialityLevel,
  ConfidentialityLevelValue,
} from '../value-objects/confidentiality-level.vo';

type CaseFileEntityProps = {
  internalCode: string;
  clientId: string;
  subject: string;
  processType: string;
  status: CaseStatusValue;
  responsibleUserId: string | null;
  openedAt: Date;
  closedAt: Date | null;
  confidentialityLevel: ConfidentialityLevelValue;
  createdAt: Date;
  updatedAt: Date;
};

type CreateCaseFileEntityProps = {
  id: string;
  internalCode: string;
  clientId: string;
  subject: string;
  processType: string;
  status?: string;
  responsibleUserId?: string | null;
  openedAt?: Date;
  closedAt?: Date | null;
  confidentialityLevel?: string;
  createdAt: Date;
  updatedAt: Date;
};

export class CaseFileEntity extends BaseEntity<CaseFileId> {
  private constructor(id: CaseFileId, private readonly props: CaseFileEntityProps) {
    super(id);
  }

  static create(props: CreateCaseFileEntityProps): CaseFileEntity {
    return new CaseFileEntity(CaseFileId.create(props.id), {
      internalCode: this.normalizeRequiredText(props.internalCode, 'Internal code'),
      clientId: this.normalizeRequiredText(props.clientId, 'Client id'),
      subject: this.normalizeRequiredText(props.subject, 'Subject'),
      processType: this.normalizeRequiredText(props.processType, 'Process type'),
      status: CaseStatusValue.create(props.status ?? CaseStatus.OPEN),
      responsibleUserId: this.normalizeOptionalId(props.responsibleUserId),
      openedAt: props.openedAt ?? new Date(),
      closedAt: props.closedAt ?? null,
      confidentialityLevel: ConfidentialityLevelValue.create(
        props.confidentialityLevel ?? ConfidentialityLevel.STANDARD,
      ),
      createdAt: props.createdAt,
      updatedAt: props.updatedAt,
    });
  }

  changeStatus(status: string): void {
    const nextStatus = CaseStatusValue.create(status);

    this.props.status = nextStatus;

    if (
      nextStatus.value === CaseStatus.CLOSED ||
      nextStatus.value === CaseStatus.ARCHIVED
    ) {
      this.props.closedAt = this.props.closedAt ?? new Date();
      return;
    }

    this.props.closedAt = null;
  }

  get internalCode(): string {
    return this.props.internalCode;
  }

  get clientId(): string {
    return this.props.clientId;
  }

  get subject(): string {
    return this.props.subject;
  }

  get processType(): string {
    return this.props.processType;
  }

  get status(): CaseStatusValue {
    return this.props.status;
  }

  get responsibleUserId(): string | null {
    return this.props.responsibleUserId;
  }

  get openedAt(): Date {
    return this.props.openedAt;
  }

  get closedAt(): Date | null {
    return this.props.closedAt;
  }

  get confidentialityLevel(): ConfidentialityLevelValue {
    return this.props.confidentialityLevel;
  }

  get createdAt(): Date {
    return this.props.createdAt;
  }

  get updatedAt(): Date {
    return this.props.updatedAt;
  }

  private static normalizeRequiredText(value: string, fieldName: string): string {
    const normalizedValue = value.trim();

    if (!normalizedValue) {
      throw new DomainValidationError(`${fieldName} is required.`);
    }

    return normalizedValue;
  }

  private static normalizeOptionalId(value?: string | null): string | null {
    if (value === undefined || value === null) {
      return null;
    }

    const normalizedValue = value.trim();

    return normalizedValue ? normalizedValue : null;
  }
}
