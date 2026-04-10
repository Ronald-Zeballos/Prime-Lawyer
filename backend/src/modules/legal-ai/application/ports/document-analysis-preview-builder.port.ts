import { CaseFileEntity } from '../../../case-files/domain/entities/case-file.entity';
import { DocumentEntity } from '../../../document-management/domain/entities/document.entity';
import { DocumentAnalysisPreviewDto } from '../dto/document-analysis-preview.dto';

export const DOCUMENT_ANALYSIS_PREVIEW_BUILDER = Symbol(
  'DOCUMENT_ANALYSIS_PREVIEW_BUILDER',
);

export type BuildDocumentAnalysisPreviewCommand = {
  sourceDocument: DocumentEntity;
  sourceCaseFile: CaseFileEntity;
  candidateCaseFiles: CaseFileEntity[];
};

export interface DocumentAnalysisPreviewBuilder {
  build(
    command: BuildDocumentAnalysisPreviewCommand,
  ): DocumentAnalysisPreviewDto;
}
