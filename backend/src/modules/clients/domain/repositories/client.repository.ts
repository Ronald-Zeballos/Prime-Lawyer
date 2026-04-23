import { ClientEntity } from '../entities/client.entity';
import { ClientId } from '../value-objects/client-id.vo';
import { DocumentNumber } from '../value-objects/document-number.vo';

export const CLIENT_REPOSITORY = Symbol('CLIENT_REPOSITORY');

export interface ClientRepository {
  findById(id: ClientId): Promise<ClientEntity | null>;
  findByDocumentNumber(
    documentNumber: DocumentNumber,
  ): Promise<ClientEntity | null>;
  countLinkedCaseFiles(id: ClientId): Promise<number>;
  search(term?: string): Promise<ClientEntity[]>;
  create(client: ClientEntity): Promise<ClientEntity>;
  update(client: ClientEntity): Promise<ClientEntity>;
  delete(id: ClientId): Promise<void>;
}
