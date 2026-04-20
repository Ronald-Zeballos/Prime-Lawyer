import { Inject, Injectable } from '@nestjs/common';
import {
  DocumentFileStorage,
  ReadStoredDocumentFileQuery,
  ReadStoredDocumentFileResult,
  StoreDocumentFileCommand,
  StoredDocumentFile,
} from '../../application/use-cases/register-document/document-file-storage.port';
import {
  OBJECT_STORAGE,
  ObjectStorage,
} from '../../../storage-management/infrastructure/adapters/object-storage.adapter';

@Injectable()
export class LocalDocumentFileStorageAdapter implements DocumentFileStorage {
  constructor(
    @Inject(OBJECT_STORAGE)
    private readonly objectStorage: ObjectStorage,
  ) {}

  async store(command: StoreDocumentFileCommand): Promise<StoredDocumentFile> {
    const storedObject = await this.objectStorage.store({
      directoryPath: `documents/${command.caseFileId}`,
      originalName: command.originalName,
      buffer: command.buffer,
    });

    return {
      storagePath: storedObject.storagePath,
      hash: storedObject.hash,
    };
  }

  async read(
    query: ReadStoredDocumentFileQuery,
  ): Promise<ReadStoredDocumentFileResult> {
    return this.objectStorage.read({
      storagePath: query.storagePath,
    });
  }
}
