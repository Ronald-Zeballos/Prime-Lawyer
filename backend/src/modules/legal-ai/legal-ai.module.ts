import { Module } from '@nestjs/common';
import { CaseFilesModule } from '../case-files/case-files.module';
import { DocumentManagementModule } from '../document-management/document-management.module';
import { IdentityAccessModule } from '../identity-access/identity-access.module';
import { AnalyzeDocumentPreviewUseCase } from './application/use-cases/analyze-document-preview/analyze-document-preview.use-case';
import { DOCUMENT_ANALYSIS_PREVIEW_BUILDER } from './application/ports/document-analysis-preview-builder.port';
import { HeuristicDocumentAnalysisPreviewBuilderService } from './infrastructure/services/heuristic-document-analysis-preview-builder.service';
import { LegalAiController } from './presentation/controllers/legal-ai.controller';

@Module({
  imports: [IdentityAccessModule, DocumentManagementModule, CaseFilesModule],
  controllers: [LegalAiController],
  providers: [
    AnalyzeDocumentPreviewUseCase,
    {
      provide: DOCUMENT_ANALYSIS_PREVIEW_BUILDER,
      useClass: HeuristicDocumentAnalysisPreviewBuilderService,
    },
  ],
})
export class LegalAiModule {}
