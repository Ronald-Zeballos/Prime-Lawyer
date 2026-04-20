export const OBJECT_STORAGE = Symbol('OBJECT_STORAGE');

export type StoreObjectCommand = {
  directoryPath: string;
  originalName: string;
  buffer: Buffer;
};

export type StoredObject = {
  storagePath: string;
  hash: string;
  size: number;
};

export type ReadStoredObjectQuery = {
  storagePath: string;
};

export type ReadStoredObjectResult = {
  buffer: Buffer;
};

export interface ObjectStorage {
  store(command: StoreObjectCommand): Promise<StoredObject>;
  read(query: ReadStoredObjectQuery): Promise<ReadStoredObjectResult>;
}
