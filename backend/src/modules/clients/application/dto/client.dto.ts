import { ClientEntity } from '../../domain/entities/client.entity';

export type ClientDto = {
  id: string;
  firstName: string;
  lastName: string;
  documentNumber: string;
  phone: string | null;
  email: string | null;
  address: string | null;
  notes: string | null;
  createdAt: Date;
  updatedAt: Date;
};

export function toClientDto(client: ClientEntity): ClientDto {
  return {
    id: client.id.value,
    firstName: client.firstName,
    lastName: client.lastName,
    documentNumber: client.documentNumber.value,
    phone: client.phone,
    email: client.email,
    address: client.address,
    notes: client.notes,
    createdAt: client.createdAt,
    updatedAt: client.updatedAt,
  };
}
