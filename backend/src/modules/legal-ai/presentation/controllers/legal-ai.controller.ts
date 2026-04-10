import { Controller, Get, Param, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../../../identity-access/presentation/guards/jwt-auth.guard';
import { AnalyzeDocumentPreviewUseCase } from '../../application/use-cases/analyze-document-preview/analyze-document-preview.use-case';
import { DocumentAnalysisPreviewResponse } from '../responses/document-analysis-preview.response';

@Controller('legal-ai')
@UseGuards(JwtAuthGuard)
export class LegalAiController {
  constructor(
    private readonly analyzeDocumentPreviewUseCase: AnalyzeDocumentPreviewUseCase,
  ) {}

  @Get('documents/:documentId/analysis-preview')
  async analyzeDocumentPreview(
    @Param('documentId') documentId: string,
  ): Promise<DocumentAnalysisPreviewResponse> {
    const analysisPreview = await this.analyzeDocumentPreviewUseCase.execute({
      documentId,
    });

    return DocumentAnalysisPreviewResponse.fromDto(analysisPreview);
  }
}
