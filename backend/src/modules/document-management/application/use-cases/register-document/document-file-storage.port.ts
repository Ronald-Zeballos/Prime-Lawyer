export const DOCUMENT_FILE_STORAGE = Symbol('DOCUMENT_FILE_STORAGE');

export type StoreDocumentFileCommand = {
  caseFileId: string;
  originalName: string;
  buffer: Buffer;
};

export type StoredDocumentFile = {
  storagePath: string;
  hash: string;
};

export type ReadStoredDocumentFileQuery = {
  storagePath: string;
};

export type ReadStoredDocumentFileResult = {
  buffer: Buffer;
};

export interface DocumentFileStorage {
  store(command: StoreDocumentFileCommand): Promise<StoredDocumentFile>;
  read(query: ReadStoredDocumentFileQuery): Promise<ReadStoredDocumentFileResult>;
}
