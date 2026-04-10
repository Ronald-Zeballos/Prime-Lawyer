import { Inject, Injectable } from '@nestjs/common';
import { NotFoundError } from '../../../../../shared/application/errors/not-found.error';
import { UseCase } from '../../../../../shared/application/use-case';
import {
  DOCUMENT_REPOSITORY,
  DocumentRepository,
} from '../../../domain/repositories/document.repository';
import { DocumentId } from '../../../domain/value-objects/document-id.vo';
import {
  DOCUMENT_FILE_STORAGE,
  DocumentFileStorage,
} from '../register-document/document-file-storage.port';

export type GetDocumentFileQuery = {
  id: string;
};

export type DocumentFileDto = {
  fileName: string;
  fileType: string;
  buffer: Buffer;
};

@Injectable()
export class GetDocumentFileUseCase
  implements UseCase<GetDocumentFileQuery, DocumentFileDto>
{
  constructor(
    @Inject(DOCUMENT_REPOSITORY)
    private readonly documentRepository: DocumentRepository,
    @Inject(DOCUMENT_FILE_STORAGE)
    private readonly documentFileStorage: DocumentFileStorage,
  ) {}

  async execute(query: GetDocumentFileQuery): Promise<DocumentFileDto> {
    const document = await this.documentRepository.findById(
      DocumentId.create(query.id),
    );

    if (!document) {
      throw new NotFoundError('Document was not found.');
    }

    const storedFile = await this.documentFileStorage.read({
      storagePath: document.storagePath,
    });

    return {
      fileName: document.originalName,
      fileType: document.fileType.value,
      buffer: storedFile.buffer,
    };
  }
}
