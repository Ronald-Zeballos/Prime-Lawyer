import { Inject, Injectable } from '@nestjs/common';
import {
  OBJECT_STORAGE,
  ObjectStorage,
} from '../../../storage-management/infrastructure/adapters/object-storage.adapter';
import {
  ContractPdfStorage,
  ReadContractPdfQuery,
  ReadContractPdfResult,
  StoreContractPdfCommand,
  StoredContractPdf,
} from '../../application/use-cases/generate-contract-from-template/contract-pdf-storage.port';

@Injectable()
export class LocalContractPdfStorageAdapter implements ContractPdfStorage {
  constructor(
    @Inject(OBJECT_STORAGE)
    private readonly objectStorage: ObjectStorage,
  ) {}

  async store(command: StoreContractPdfCommand): Promise<StoredContractPdf> {
    const storedObject = await this.objectStorage.store({
      directoryPath: `contracts/${command.userId}/${command.contractInstanceId}`,
      originalName: command.fileName,
      buffer: command.buffer,
    });

    return {
      storagePath: storedObject.storagePath,
    };
  }

  async read(query: ReadContractPdfQuery): Promise<ReadContractPdfResult> {
    return this.objectStorage.read({
      storagePath: query.storagePath,
    });
  }
}
