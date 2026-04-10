import { DocumentAnalysisPreviewDto } from '../../application/dto/document-analysis-preview.dto';

export class DocumentAnalysisPreviewResponse {
  static fromDto(
    dto: DocumentAnalysisPreviewDto,
  ): DocumentAnalysisPreviewDto {
    return dto;
  }
}
