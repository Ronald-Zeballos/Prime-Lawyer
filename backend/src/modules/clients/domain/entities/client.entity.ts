import { BaseEntity } from '../../../../shared/domain/base-entity';
import { DomainValidationError } from '../../../../shared/domain/errors/domain-validation.error';
import { ClientId } from '../value-objects/client-id.vo';
import { DocumentNumber } from '../value-objects/document-number.vo';

type ClientEntityProps = {
  firstName: string;
  lastName: string;
  documentNumber: DocumentNumber;
  phone: string | null;
  email: string | null;
  address: string | null;
  notes: string | null;
  createdAt: Date;
  updatedAt: Date;
};

type CreateClientEntityProps = {
  id: string;
  firstName: string;
  lastName: string;
  documentNumber: string;
  phone?: string | null;
  email?: string | null;
  address?: string | null;
  notes?: string | null;
  createdAt: Date;
  updatedAt: Date;
};

type UpdateClientEntityProps = {
  firstName?: string;
  lastName?: string;
  documentNumber?: string;
  phone?: string | null;
  email?: string | null;
  address?: string | null;
  notes?: string | null;
};

export class ClientEntity extends BaseEntity<ClientId> {
  private constructor(id: ClientId, private readonly props: ClientEntityProps) {
    super(id);
  }

  static create(props: CreateClientEntityProps): ClientEntity {
    return new ClientEntity(ClientId.create(props.id), {
      firstName: this.normalizeRequiredText(props.firstName, 'First name'),
      lastName: this.normalizeRequiredText(props.lastName, 'Last name'),
      documentNumber: DocumentNumber.create(props.documentNumber),
      phone: this.normalizeOptionalText(props.phone),
      email: this.normalizeOptionalEmail(props.email),
      address: this.normalizeOptionalText(props.address),
      notes: this.normalizeOptionalText(props.notes),
      createdAt: props.createdAt,
      updatedAt: props.updatedAt,
    });
  }

  update(props: UpdateClientEntityProps): void {
    if (props.firstName !== undefined) {
      this.props.firstName = ClientEntity.normalizeRequiredText(
        props.firstName,
        'First name',
      );
    }

    if (props.lastName !== undefined) {
      this.props.lastName = ClientEntity.normalizeRequiredText(
        props.lastName,
        'Last name',
      );
    }

    if (props.documentNumber !== undefined) {
      this.props.documentNumber = DocumentNumber.create(props.documentNumber);
    }

    if (props.phone !== undefined) {
      this.props.phone = ClientEntity.normalizeOptionalText(props.phone);
    }

    if (props.email !== undefined) {
      this.props.email = ClientEntity.normalizeOptionalEmail(props.email);
    }

    if (props.address !== undefined) {
      this.props.address = ClientEntity.normalizeOptionalText(props.address);
    }

    if (props.notes !== undefined) {
      this.props.notes = ClientEntity.normalizeOptionalText(props.notes);
    }
  }

  get firstName(): string {
    return this.props.firstName;
  }

  get lastName(): string {
    return this.props.lastName;
  }

  get documentNumber(): DocumentNumber {
    return this.props.documentNumber;
  }

  get phone(): string | null {
    return this.props.phone;
  }

  get email(): string | null {
    return this.props.email;
  }

  get address(): string | null {
    return this.props.address;
  }

  get notes(): string | null {
    return this.props.notes;
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

  private static normalizeOptionalText(value?: string | null): string | null {
    if (value === undefined || value === null) {
      return null;
    }

    const normalizedValue = value.trim();

    return normalizedValue ? normalizedValue : null;
  }

  private static normalizeOptionalEmail(value?: string | null): string | null {
    const normalizedValue = this.normalizeOptionalText(value);

    if (!normalizedValue) {
      return null;
    }

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    if (!emailRegex.test(normalizedValue.toLowerCase())) {
      throw new DomainValidationError('Email format is invalid.');
    }

    return normalizedValue.toLowerCase();
  }
}
