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

export interface DocumentFileStorage {
  store(command: StoreDocumentFileCommand): Promise<StoredDocumentFile>;
}
