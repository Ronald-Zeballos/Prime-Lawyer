import { ClientDto } from '../../application/dto/client.dto';

export class ClientResponse {
  id!: string;
  firstName!: string;
  lastName!: string;
  documentNumber!: string;
  phone!: string | null;
  email!: string | null;
  address!: string | null;
  notes!: string | null;
  createdAt!: Date;
  updatedAt!: Date;

  static fromDto(dto: ClientDto): ClientResponse {
    return {
      id: dto.id,
      firstName: dto.firstName,
      lastName: dto.lastName,
      documentNumber: dto.documentNumber,
      phone: dto.phone,
      email: dto.email,
      address: dto.address,
      notes: dto.notes,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    };
  }
}
