import { Inject, Injectable } from '@nestjs/common';
import { ForbiddenError } from '../../../../../shared/application/errors/forbidden.error';
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
} from '../../../../document-management/domain/repositories/document.repository';
import { DocumentId } from '../../../../document-management/domain/value-objects/document-id.vo';
import { SearchSemanticContentUseCase } from '../../../../semantic-search/application/use-cases/search-semantic-content/search-semantic-content.use-case';
import { DocumentAnalysisPreviewDto } from '../../dto/document-analysis-preview.dto';
import {
  DOCUMENT_ANALYSIS_PREVIEW_BUILDER,
  DocumentAnalysisPreviewBuilder,
} from '../../ports/document-analysis-preview-builder.port';

export type AnalyzeDocumentPreviewQuery = {
  documentId: string;
  requesterId: string;
};

@Injectable()
export class AnalyzeDocumentPreviewUseCase
  implements UseCase<AnalyzeDocumentPreviewQuery, DocumentAnalysisPreviewDto>
{
  constructor(
    @Inject(DOCUMENT_REPOSITORY)
    private readonly documentRepository: DocumentRepository,
    @Inject(CASE_FILE_REPOSITORY)
    private readonly caseFileRepository: CaseFileRepository,
    private readonly searchSemanticContentUseCase: SearchSemanticContentUseCase,
    @Inject(DOCUMENT_ANALYSIS_PREVIEW_BUILDER)
    private readonly documentAnalysisPreviewBuilder: DocumentAnalysisPreviewBuilder,
  ) {}

  async execute(
    query: AnalyzeDocumentPreviewQuery,
  ): Promise<DocumentAnalysisPreviewDto> {
    const document = await this.documentRepository.findById(
      DocumentId.create(query.documentId),
    );

    if (!document) {
      throw new NotFoundError('Document was not found.');
    }

    const sourceCaseFile = await this.caseFileRepository.findById(
      CaseFileId.create(document.caseFileId),
    );

    if (!sourceCaseFile) {
      throw new NotFoundError('Source case file was not found.');
    }

    if (!sourceCaseFile.belongsTo(query.requesterId)) {
      throw new ForbiddenError(
        'This document is not available for the current user.',
      );
    }

    const semanticSearch = await this.searchSemanticContentUseCase.execute({
      requesterId: query.requesterId,
      caseFileId: sourceCaseFile.id.value,
      documentId: document.id.value,
      processType: sourceCaseFile.processType,
      limit: 5,
    });

    return this.documentAnalysisPreviewBuilder.build({
      sourceDocument: document,
      sourceCaseFile,
      semanticSearch,
    });
  }
}
