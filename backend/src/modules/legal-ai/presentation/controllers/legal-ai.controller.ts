import { Body, Controller, Get, Param, Post, Req, UseGuards } from '@nestjs/common';
import { Request } from 'express';
import { AuthenticatedUserDto } from '../../../identity-access/application/dto/authenticated-user.dto';
import { JwtAuthGuard } from '../../../identity-access/presentation/guards/jwt-auth.guard';
import { AnalyzeDocumentPreviewUseCase } from '../../application/use-cases/analyze-document-preview/analyze-document-preview.use-case';
import { AnswerQuestionAboutCaseUseCase } from '../../application/use-cases/answer-question-about-case/answer-question-about-case.use-case';
import { AskContextualLegalQuestionRequest } from '../requests/ask-contextual-legal-question.request';
import { ContextualLegalAnswerResponse } from '../responses/contextual-legal-answer.response';
import { DocumentAnalysisPreviewResponse } from '../responses/document-analysis-preview.response';

@Controller('legal-ai')
@UseGuards(JwtAuthGuard)
export class LegalAiController {
  constructor(
    private readonly analyzeDocumentPreviewUseCase: AnalyzeDocumentPreviewUseCase,
    private readonly answerQuestionAboutCaseUseCase: AnswerQuestionAboutCaseUseCase,
  ) {}

  @Post('consultations')
  async askContextualQuestion(
    @Body() request: AskContextualLegalQuestionRequest,
    @Req()
    httpRequest: Request & {
      user: AuthenticatedUserDto;
    },
  ): Promise<ContextualLegalAnswerResponse> {
    const answer = await this.answerQuestionAboutCaseUseCase.execute({
      requesterId: httpRequest.user.id,
      question: request.question,
      caseFileId: request.caseFileId,
      documentId: request.documentId,
      processType: request.processType,
      limit: request.limit,
    });

    return ContextualLegalAnswerResponse.fromDto(answer);
  }

  @Get('documents/:documentId/analysis-preview')
  async analyzeDocumentPreview(
    @Param('documentId') documentId: string,
    @Req()
    httpRequest: Request & {
      user: AuthenticatedUserDto;
    },
  ): Promise<DocumentAnalysisPreviewResponse> {
    const analysisPreview = await this.analyzeDocumentPreviewUseCase.execute({
      documentId,
      requesterId: httpRequest.user.id,
    });

    return DocumentAnalysisPreviewResponse.fromDto(analysisPreview);
  }
}
