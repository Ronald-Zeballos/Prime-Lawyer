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
  clientId: string | null;
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
  publishedAt: Date | null;
  confidentialityLevel: ConfidentialityLevelValue;
  createdAt: Date;
  updatedAt: Date;
};

type CreateCaseFileEntityProps = {
  id: string;
  internalCode: string;
  clientId?: string | null;
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
  publishedAt?: Date | null;
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
      clientId: this.normalizeOptionalId(props.clientId),
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
      publishedAt: props.publishedAt ?? null,
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
    if (this.isClosedStatus(nextStatus.value)) {
      this.props.closedAt = this.props.closedAt ?? new Date();
      if (!this.isPublishedToRepository) {
        this.props.visibility = CaseVisibility.PRIVATE;
        this.props.publishedAt = null;
        this.props.knowledgeStatus = this.computeKnowledgeStatusForClosedCase();
      }
    } else {
      this.props.closedAt = null;
      this.props.visibility = CaseVisibility.PRIVATE;
      this.props.publishedAt = null;
      this.props.knowledgeStatus = KnowledgeStatus.DRAFT;
    }

    this.touch();
  }

  publishToRepository(publishedAt?: Date): void {
    if (!this.isClosedStatus(this.props.status.value)) {
      throw new DomainValidationError(
        'Only closed or archived case files can be published to the collaborative repository.',
      );
    }

    if (
      this.props.confidentialityLevel.value ===
      ConfidentialityLevel.HIGHLY_CONFIDENTIAL
    ) {
      throw new DomainValidationError(
        'Highly confidential case files cannot be published to the collaborative repository.',
      );
    }

    const eventDate = publishedAt ?? new Date();

    this.props.visibility = CaseVisibility.COMMUNITY;
    this.props.knowledgeStatus = KnowledgeStatus.PUBLISHED;
    this.props.publishedAt = this.props.publishedAt ?? eventDate;
    this.touch(eventDate);
  }

  unpublishFromRepository(): void {
    this.props.visibility = CaseVisibility.PRIVATE;
    this.props.publishedAt = null;
    this.props.knowledgeStatus = this.isClosedStatus(this.props.status.value)
      ? this.computeKnowledgeStatusForClosedCase()
      : KnowledgeStatus.DRAFT;
    this.touch();
  }

  get internalCode(): string {
    return this.props.internalCode;
  }

  get ownerUserId(): string {
    return this.props.ownerUserId;
  }

  get clientId(): string | null {
    return this.props.clientId;
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

  get publishedAt(): Date | null {
    return this.props.publishedAt;
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

  get isPublishedToRepository(): boolean {
    return (
      this.props.visibility === CaseVisibility.COMMUNITY &&
      this.props.knowledgeStatus === KnowledgeStatus.PUBLISHED
    );
  }

  get canBePublishedToRepository(): boolean {
    return (
      this.isClosedStatus(this.props.status.value) &&
      this.props.confidentialityLevel.value !==
        ConfidentialityLevel.HIGHLY_CONFIDENTIAL
    );
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

  private isClosedStatus(status: string): boolean {
    return status === CaseStatus.CLOSED || status === CaseStatus.ARCHIVED;
  }

  private computeKnowledgeStatusForClosedCase(): KnowledgeStatus {
    if (
      this.props.confidentialityLevel.value ===
      ConfidentialityLevel.HIGHLY_CONFIDENTIAL
    ) {
      return KnowledgeStatus.EXCLUDED;
    }

    return KnowledgeStatus.ELIGIBLE;
  }
}
