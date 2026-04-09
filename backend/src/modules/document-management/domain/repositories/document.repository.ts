import { DocumentEntity } from '../entities/document.entity';
import { DocumentId } from '../value-objects/document-id.vo';

export const DOCUMENT_REPOSITORY = Symbol('DOCUMENT_REPOSITORY');

export interface DocumentRepository {
  findById(id: DocumentId): Promise<DocumentEntity | null>;
  findByCaseFileId(caseFileId: string): Promise<DocumentEntity[]>;
  create(document: DocumentEntity): Promise<DocumentEntity>;
}
