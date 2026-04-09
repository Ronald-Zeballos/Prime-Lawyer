import { Inject, Injectable } from '@nestjs/common';
import { NotFoundError } from '../../../../../shared/application/errors/not-found.error';
import { UseCase } from '../../../../../shared/application/use-case';
import {
  CASE_FILE_REPOSITORY,
  CaseFileRepository,
} from '../../../../case-files/domain/repositories/case-file.repository';
import { CaseFileId } from '../../../../case-files/domain/value-objects/case-file-id.vo';
import {
  DOCUMENT_REPOSITORY,
  DocumentRepository,
} from '../../../domain/repositories/document.repository';
import { DocumentDto, toDocumentDto } from '../../dto/document.dto';

export type ListCaseDocumentsQuery = {
  caseFileId: string;
};

@Injectable()
export class ListCaseDocumentsUseCase
  implements UseCase<ListCaseDocumentsQuery, DocumentDto[]>
{
  constructor(
    @Inject(DOCUMENT_REPOSITORY)
    private readonly documentRepository: DocumentRepository,
    @Inject(CASE_FILE_REPOSITORY)
    private readonly caseFileRepository: CaseFileRepository,
  ) {}

  async execute(query: ListCaseDocumentsQuery): Promise<DocumentDto[]> {
    const caseFile = await this.caseFileRepository.findById(
      CaseFileId.create(query.caseFileId),
    );

    if (!caseFile) {
      throw new NotFoundError('Case file was not found.');
    }

    const documents = await this.documentRepository.findByCaseFileId(
      query.caseFileId,
    );

    return documents.map(toDocumentDto);
  }
}
