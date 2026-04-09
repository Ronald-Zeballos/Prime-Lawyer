import { Inject, Injectable } from '@nestjs/common';
import { NotFoundError } from '../../../../../shared/application/errors/not-found.error';
import { UseCase } from '../../../../../shared/application/use-case';
import {
  DOCUMENT_REPOSITORY,
  DocumentRepository,
} from '../../../domain/repositories/document.repository';
import { DocumentId } from '../../../domain/value-objects/document-id.vo';
import { DocumentDto, toDocumentDto } from '../../dto/document.dto';

export type GetDocumentQuery = {
  id: string;
};

@Injectable()
export class GetDocumentUseCase implements UseCase<GetDocumentQuery, DocumentDto> {
  constructor(
    @Inject(DOCUMENT_REPOSITORY)
    private readonly documentRepository: DocumentRepository,
  ) {}

  async execute(query: GetDocumentQuery): Promise<DocumentDto> {
    const document = await this.documentRepository.findById(
      DocumentId.create(query.id),
    );

    if (!document) {
      throw new NotFoundError('Document was not found.');
    }

    return toDocumentDto(document);
  }
}
