import { Module } from '@nestjs/common';
import { CaseFilesModule } from '../case-files/case-files.module';
import { DocumentManagementModule } from '../document-management/document-management.module';
import { IdentityAccessModule } from '../identity-access/identity-access.module';
import { SemanticSearchModule } from '../semantic-search/semantic-search.module';
import { AnswerQuestionAboutCaseUseCase } from './application/use-cases/answer-question-about-case/answer-question-about-case.use-case';
import { AnalyzeDocumentPreviewUseCase } from './application/use-cases/analyze-document-preview/analyze-document-preview.use-case';
import { CONTEXTUAL_LEGAL_ANSWER_BUILDER } from './application/ports/contextual-legal-answer-builder.port';
import { DOCUMENT_ANALYSIS_PREVIEW_BUILDER } from './application/ports/document-analysis-preview-builder.port';
import { HeuristicContextualLegalAnswerBuilderService } from './infrastructure/services/heuristic-contextual-legal-answer-builder.service';
import { HeuristicDocumentAnalysisPreviewBuilderService } from './infrastructure/services/heuristic-document-analysis-preview-builder.service';
import { LegalAiController } from './presentation/controllers/legal-ai.controller';

@Module({
  imports: [
    IdentityAccessModule,
    DocumentManagementModule,
    CaseFilesModule,
    SemanticSearchModule,
  ],
  controllers: [LegalAiController],
  providers: [
    AnalyzeDocumentPreviewUseCase,
    AnswerQuestionAboutCaseUseCase,
    {
      provide: DOCUMENT_ANALYSIS_PREVIEW_BUILDER,
      useClass: HeuristicDocumentAnalysisPreviewBuilderService,
    },
    {
      provide: CONTEXTUAL_LEGAL_ANSWER_BUILDER,
      useClass: HeuristicContextualLegalAnswerBuilderService,
    },
  ],
})
export class LegalAiModule {}
