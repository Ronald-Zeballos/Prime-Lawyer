import { BaseEntity } from '../../../../shared/domain/base-entity';
import { DomainValidationError } from '../../../../shared/domain/errors/domain-validation.error';

export enum AuditEntityType {
  AUTH = 'AUTH',
  CLIENT = 'CLIENT',
  CASE_FILE = 'CASE_FILE',
  DOCUMENT = 'DOCUMENT',
}

type AuditLogEntityProps = {
  entityType: AuditEntityType;
  entityId: string;
  caseFileId: string | null;
  action: string;
  performedById: string | null;
  metadata: Record<string, unknown> | null;
  createdAt: Date;
};

type CreateAuditLogEntityProps = {
  id: string;
  entityType: AuditEntityType | string;
  entityId: string;
  caseFileId?: string | null;
  action: string;
  performedById?: string | null;
  metadata?: Record<string, unknown> | null;
  createdAt: Date;
};

export class AuditLogEntity extends BaseEntity<string> {
  private constructor(id: string, private readonly props: AuditLogEntityProps) {
    super(id);
  }

  static create(props: CreateAuditLogEntityProps): AuditLogEntity {
    return new AuditLogEntity(this.normalizeRequiredText(props.id, 'Audit log id'), {
      entityType: this.normalizeEntityType(props.entityType),
      entityId: this.normalizeRequiredText(props.entityId, 'Entity id'),
      caseFileId: this.normalizeOptionalText(props.caseFileId),
      action: this.normalizeRequiredText(props.action, 'Action'),
      performedById: this.normalizeOptionalText(props.performedById),
      metadata: this.normalizeMetadata(props.metadata),
      createdAt: props.createdAt,
    });
  }

  get entityType(): AuditEntityType {
    return this.props.entityType;
  }

  get entityId(): string {
    return this.props.entityId;
  }

  get caseFileId(): string | null {
    return this.props.caseFileId;
  }

  get action(): string {
    return this.props.action;
  }

  get performedById(): string | null {
    return this.props.performedById;
  }

  get metadata(): Record<string, unknown> | null {
    return this.props.metadata;
  }

  get createdAt(): Date {
    return this.props.createdAt;
  }

  private static normalizeEntityType(value: AuditEntityType | string): AuditEntityType {
    const normalizedValue = this.normalizeRequiredText(value, 'Entity type').toUpperCase();

    if (!Object.values(AuditEntityType).includes(normalizedValue as AuditEntityType)) {
      throw new DomainValidationError('Audit entity type is invalid.');
    }

    return normalizedValue as AuditEntityType;
  }

  private static normalizeMetadata(
    value?: Record<string, unknown> | null,
  ): Record<string, unknown> | null {
    if (value === undefined || value === null) {
      return null;
    }

    if (typeof value !== 'object' || Array.isArray(value)) {
      throw new DomainValidationError('Audit metadata must be an object.');
    }

    return value;
  }

  private static normalizeRequiredText(value: string, fieldName: string): string {
    const normalizedValue = value.trim();

    if (!normalizedValue) {
      throw new DomainValidationError(`${fieldName} is required.`);
    }

    return normalizedValue;
  }

  private static normalizeOptionalText(value?: string | null): string | null {
    if (value === undefined || value === null) {
      return null;
    }

    const normalizedValue = value.trim();

    return normalizedValue ? normalizedValue : null;
  }
}
