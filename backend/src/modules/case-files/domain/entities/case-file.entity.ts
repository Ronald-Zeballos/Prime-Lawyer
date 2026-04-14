import { BaseEntity } from '../../../../shared/domain/base-entity';
import { DomainValidationError } from '../../../../shared/domain/errors/domain-validation.error';
import { CaseFileId } from '../value-objects/case-file-id.vo';
import { CaseStatus, CaseStatusValue } from '../value-objects/case-status.vo';
import {
  ConfidentialityLevel,
  ConfidentialityLevelValue,
} from '../value-objects/confidentiality-level.vo';

export enum CaseVisibility {
  PRIVATE = 'PRIVATE',
  COMMUNITY = 'COMMUNITY',
}

export enum KnowledgeStatus {
  DRAFT = 'DRAFT',
  ELIGIBLE = 'ELIGIBLE',
  PUBLISHED = 'PUBLISHED',
  EXCLUDED = 'EXCLUDED',
}

type CaseFileEntityProps = {
  internalCode: string;
  ownerUserId: string;
  title: string;
  description: string | null;
  processType: string;
  status: CaseStatusValue;
  responsibleUserId: string | null;
  openedAt: Date;
  closedAt: Date | null;
  visibility: CaseVisibility;
  knowledgeStatus: KnowledgeStatus;
  confidentialityLevel: ConfidentialityLevelValue;
  createdAt: Date;
  updatedAt: Date;
};

type CreateCaseFileEntityProps = {
  id: string;
  internalCode: string;
  ownerUserId: string;
  title: string;
  description?: string | null;
  processType: string;
  status?: string;
  responsibleUserId?: string | null;
  openedAt?: Date;
  closedAt?: Date | null;
  visibility?: string;
  knowledgeStatus?: string;
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
      ownerUserId: this.normalizeRequiredText(props.ownerUserId, 'Owner user id'),
      title: this.normalizeRequiredText(props.title, 'Case title'),
      description: this.normalizeOptionalText(props.description),
      processType: this.normalizeRequiredText(props.processType, 'Process type'),
      status: CaseStatusValue.create(props.status ?? CaseStatus.OPEN),
      responsibleUserId: this.normalizeOptionalId(props.responsibleUserId),
      openedAt: props.openedAt ?? new Date(),
      closedAt: props.closedAt ?? null,
      visibility: this.normalizeVisibility(props.visibility),
      knowledgeStatus: this.normalizeKnowledgeStatus(props.knowledgeStatus),
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
    this.touch();

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

  get ownerUserId(): string {
    return this.props.ownerUserId;
  }

  get title(): string {
    return this.props.title;
  }

  get description(): string | null {
    return this.props.description;
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

  get visibility(): CaseVisibility {
    return this.props.visibility;
  }

  get knowledgeStatus(): KnowledgeStatus {
    return this.props.knowledgeStatus;
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

  get searchText(): string {
    return [
      this.props.internalCode,
      this.props.title,
      this.props.description ?? '',
      this.props.processType,
    ]
      .map((value) => value.trim())
      .filter((value) => value.length > 0)
      .join(' | ');
  }

  belongsTo(userId: string): boolean {
    return this.props.ownerUserId === userId.trim();
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

  private static normalizeOptionalText(value?: string | null): string | null {
    if (value === undefined || value === null) {
      return null;
    }

    const normalizedValue = value.trim();

    return normalizedValue ? normalizedValue : null;
  }

  private static normalizeVisibility(value?: string): CaseVisibility {
    const normalizedValue = (value ?? CaseVisibility.PRIVATE).trim().toUpperCase();

    if (normalizedValue in CaseVisibility) {
      return normalizedValue as CaseVisibility;
    }

    throw new DomainValidationError('Case visibility is invalid.');
  }

  private static normalizeKnowledgeStatus(value?: string): KnowledgeStatus {
    const normalizedValue = (value ?? KnowledgeStatus.DRAFT).trim().toUpperCase();

    if (normalizedValue in KnowledgeStatus) {
      return normalizedValue as KnowledgeStatus;
    }

    throw new DomainValidationError('Knowledge status is invalid.');
  }

  private touch(updatedAt?: Date): void {
    this.props.updatedAt = updatedAt ?? new Date();
  }
}
