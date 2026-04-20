import { Inject, Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { ForbiddenError } from '../../../../../shared/application/errors/forbidden.error';
import { NotFoundError } from '../../../../../shared/application/errors/not-found.error';
import { UseCase } from '../../../../../shared/application/use-case';
import { DomainValidationError } from '../../../../../shared/domain/errors/domain-validation.error';
import { PrismaService } from '../../../../../shared/infrastructure/prisma/prisma.service';
import { SearchSemanticContentUseCase } from '../../../../semantic-search/application/use-cases/search-semantic-content/search-semantic-content.use-case';
import {
  CONTEXTUAL_LEGAL_ANSWER_BUILDER,
  ContextualLegalAnswerBuilder,
} from '../../ports/contextual-legal-answer-builder.port';
import {
  ContextualLegalAnswerDto,
  ContextualLegalContextCaseDto,
  ContextualLegalContextDocumentDto,
  ContextualLegalSourceCaseFileDto,
  ContextualLegalSourceDocumentDto,
} from '../../dto/contextual-legal-answer.dto';

const DEFAULT_LIMIT = 3;
const MAX_LIMIT = 5;

export type AnswerQuestionAboutCaseCommand = {
  requesterId: string;
  question: string;
  caseFileId?: string | null;
  documentId?: string | null;
  processType?: string | null;
  limit?: number | null;
};

type SourceCaseRecord = Prisma.CaseFileGetPayload<{
  select: {
    id: true;
    ownerUserId: true;
    internalCode: true;
    title: true;
    description: true;
    processType: true;
    status: true;
    visibility: true;
    knowledgeStatus: true;
  };
}>;

type SourceDocumentRecord = Prisma.DocumentGetPayload<{
  select: {
    id: true;
    caseFileId: true;
    originalName: true;
    fileType: true;
    ocrStatus: true;
    ocrText: true;
    uploadSource: true;
    caseFile: {
      select: {
        id: true;
        ownerUserId: true;
        internalCode: true;
        title: true;
        description: true;
        processType: true;
        status: true;
        visibility: true;
        knowledgeStatus: true;
      };
    };
  };
}>;

@Injectable()
export class AnswerQuestionAboutCaseUseCase
  implements UseCase<AnswerQuestionAboutCaseCommand, ContextualLegalAnswerDto>
{
  constructor(
    private readonly prisma: PrismaService,
    private readonly searchSemanticContentUseCase: SearchSemanticContentUseCase,
    @Inject(CONTEXTUAL_LEGAL_ANSWER_BUILDER)
    private readonly contextualLegalAnswerBuilder: ContextualLegalAnswerBuilder,
  ) {}

  async execute(
    command: AnswerQuestionAboutCaseCommand,
  ): Promise<ContextualLegalAnswerDto> {
    const requesterId = command.requesterId.trim();
    const question = command.question.trim();
    const caseFileId = command.caseFileId?.trim() || null;
    const documentId = command.documentId?.trim() || null;
    const processType = command.processType?.trim() || null;
    const limit = this.normalizeLimit(command.limit);

    if (!question) {
      throw new DomainValidationError('A legal question is required.');
    }

    const sourceCaseRecord = await this.resolveSourceCaseFile(
      caseFileId,
      requesterId,
    );
    const sourceDocumentRecord = await this.resolveSourceDocument(
      documentId,
      requesterId,
    );

    if (
      sourceCaseRecord &&
      sourceDocumentRecord &&
      sourceDocumentRecord.caseFileId !== sourceCaseRecord.id
    ) {
      throw new DomainValidationError(
        'The provided case file and document do not belong together.',
      );
    }

    const effectiveSourceCaseRecord =
      sourceCaseRecord ?? sourceDocumentRecord?.caseFile ?? null;

    const retrieval = await this.searchSemanticContentUseCase.execute({
      requesterId,
      text: question,
      processType,
      caseFileId,
      documentId,
      limit,
    });

    const sourceCaseFile = effectiveSourceCaseRecord
      ? this.mapSourceCaseFile(effectiveSourceCaseRecord)
      : null;
    const sourceDocument = sourceDocumentRecord
      ? this.mapSourceDocument(sourceDocumentRecord)
      : null;
    const usedContextCases = this.buildUsedContextCases(
      sourceCaseFile,
      retrieval.caseMatches,
      limit,
    );
    const usedContextDocuments = this.buildUsedContextDocuments(
      sourceDocument,
      sourceCaseFile,
      retrieval.documentMatches,
      limit,
    );
    const answerDraft = this.contextualLegalAnswerBuilder.build({
      question,
      sourceCaseFile,
      sourceDocument,
      usedContextCases,
      usedContextDocuments,
      retrieval,
    });
    const createdAt = new Date();
    const aiQuery = await this.prisma.aIQuery.create({
      data: {
        userId: requesterId,
        queryText: question,
        responseText: answerDraft.answer,
        tokensUsed: 0,
        metadata: {
          mode: 'CONTEXTUAL_HEURISTIC',
          language: answerDraft.language,
          groundingStatus: answerDraft.groundingStatus,
          sourceCaseFileId: sourceCaseFile?.id ?? null,
          sourceDocumentId: sourceDocument?.id ?? null,
          processType,
          retrieval,
          usedContextDocuments,
          disclaimer: answerDraft.disclaimer,
          limitations: answerDraft.limitations,
          recommendedNextSteps: answerDraft.recommendedNextSteps,
          followUpQuestions: answerDraft.followUpQuestions,
        },
        createdAt,
        updatedAt: createdAt,
        contextCases: usedContextCases.length > 0
          ? {
              create: usedContextCases.map((contextCase) => ({
                caseFileId: contextCase.caseFileId,
                rank: contextCase.rank,
                score: Number((contextCase.score / 100).toFixed(2)),
                snippet: contextCase.snippet,
              })),
            }
          : undefined,
      },
    });

    return {
      queryId: aiQuery.id,
      mode: 'CONTEXTUAL_HEURISTIC',
      question,
      sourceCaseFile,
      sourceDocument,
      usedContextCases,
      usedContextDocuments,
      retrieval,
      createdAt: aiQuery.createdAt,
      ...answerDraft,
    };
  }

  private async resolveSourceCaseFile(
    caseFileId: string | null,
    requesterId: string,
  ): Promise<SourceCaseRecord | null> {
    if (!caseFileId) {
      return null;
    }

    const caseFile = await this.prisma.caseFile.findUnique({
      where: { id: caseFileId },
      select: {
        id: true,
        ownerUserId: true,
        internalCode: true,
        title: true,
        description: true,
        processType: true,
        status: true,
        visibility: true,
        knowledgeStatus: true,
      },
    });

    if (!caseFile) {
      throw new NotFoundError('Source case file was not found.');
    }

    if (caseFile.ownerUserId !== requesterId) {
      throw new ForbiddenError(
        'This case file is not available for the current user.',
      );
    }

    return caseFile;
  }

  private async resolveSourceDocument(
    documentId: string | null,
    requesterId: string,
  ): Promise<SourceDocumentRecord | null> {
    if (!documentId) {
      return null;
    }

    const document = await this.prisma.document.findUnique({
      where: { id: documentId },
      select: {
        id: true,
        caseFileId: true,
        originalName: true,
        fileType: true,
        ocrStatus: true,
        ocrText: true,
        uploadSource: true,
        caseFile: {
          select: {
            id: true,
            ownerUserId: true,
            internalCode: true,
            title: true,
            description: true,
            processType: true,
            status: true,
            visibility: true,
            knowledgeStatus: true,
          },
        },
      },
    });

    if (!document) {
      throw new NotFoundError('Source document was not found.');
    }

    if (document.caseFile.ownerUserId !== requesterId) {
      throw new ForbiddenError(
        'This document is not available for the current user.',
      );
    }

    return document;
  }

  private mapSourceCaseFile(
    sourceCaseRecord: SourceCaseRecord,
  ): ContextualLegalSourceCaseFileDto {
    return {
      id: sourceCaseRecord.id,
      internalCode: sourceCaseRecord.internalCode,
      title: sourceCaseRecord.title,
      descriptionSnippet: this.buildSnippet(
        sourceCaseRecord.description ?? sourceCaseRecord.title,
      ),
      processType: sourceCaseRecord.processType,
      status: sourceCaseRecord.status,
      visibility: sourceCaseRecord.visibility,
      knowledgeStatus: sourceCaseRecord.knowledgeStatus,
    };
  }

  private mapSourceDocument(
    sourceDocumentRecord: SourceDocumentRecord,
  ): ContextualLegalSourceDocumentDto {
    return {
      id: sourceDocumentRecord.id,
      caseFileId: sourceDocumentRecord.caseFileId,
      originalName: sourceDocumentRecord.originalName,
      fileType: sourceDocumentRecord.fileType,
      ocrStatus: sourceDocumentRecord.ocrStatus,
      uploadSource: sourceDocumentRecord.uploadSource,
      snippet: this.buildSnippet(
        sourceDocumentRecord.ocrText ?? sourceDocumentRecord.originalName,
      ),
    };
  }

  private buildUsedContextCases(
    sourceCaseFile: ContextualLegalSourceCaseFileDto | null,
    caseMatches: ContextualLegalAnswerDto['retrieval']['caseMatches'],
    limit: number,
  ): ContextualLegalContextCaseDto[] {
    const contexts: ContextualLegalContextCaseDto[] = [];
    const seenCaseIds = new Set<string>();

    if (sourceCaseFile) {
      contexts.push({
        rank: 1,
        relation: 'SOURCE_CASE',
        caseFileId: sourceCaseFile.id,
        internalCode: sourceCaseFile.internalCode,
        title: sourceCaseFile.title,
        processType: sourceCaseFile.processType,
        status: sourceCaseFile.status,
        visibility: sourceCaseFile.visibility,
        knowledgeStatus: sourceCaseFile.knowledgeStatus,
        score: 100,
        snippet: sourceCaseFile.descriptionSnippet,
        matchReasons: ['Explicit consultation context.'],
      });
      seenCaseIds.add(sourceCaseFile.id);
    }

    for (const caseMatch of caseMatches.slice(0, limit)) {
      if (seenCaseIds.has(caseMatch.caseFileId)) {
        continue;
      }

      contexts.push({
        rank: contexts.length + 1,
        relation: 'SIMILAR_CASE',
        caseFileId: caseMatch.caseFileId,
        internalCode: caseMatch.internalCode,
        title: caseMatch.title,
        processType: caseMatch.processType,
        status: caseMatch.status,
        visibility: caseMatch.visibility,
        knowledgeStatus: caseMatch.knowledgeStatus,
        score: caseMatch.score,
        snippet: caseMatch.snippet,
        matchReasons: caseMatch.matchReasons,
      });
      seenCaseIds.add(caseMatch.caseFileId);
    }

    return contexts;
  }

  private buildUsedContextDocuments(
    sourceDocument: ContextualLegalSourceDocumentDto | null,
    sourceCaseFile: ContextualLegalSourceCaseFileDto | null,
    documentMatches: ContextualLegalAnswerDto['retrieval']['documentMatches'],
    limit: number,
  ): ContextualLegalContextDocumentDto[] {
    const contexts: ContextualLegalContextDocumentDto[] = [];
    const seenDocumentIds = new Set<string>();

    if (sourceDocument) {
      contexts.push({
        rank: 1,
        relation: 'SOURCE_DOCUMENT',
        documentId: sourceDocument.id,
        caseFileId: sourceDocument.caseFileId,
        caseInternalCode: sourceCaseFile?.internalCode ?? 'SOURCE',
        caseTitle: sourceCaseFile?.title ?? 'Provided document',
        processType: sourceCaseFile?.processType ?? 'SOURCE',
        status: sourceCaseFile?.status ?? 'SOURCE',
        originalName: sourceDocument.originalName,
        fileType: sourceDocument.fileType,
        ocrStatus: sourceDocument.ocrStatus,
        score: 100,
        snippet: sourceDocument.snippet,
        matchReasons: ['Explicit consultation document.'],
      });
      seenDocumentIds.add(sourceDocument.id);
    }

    for (const documentMatch of documentMatches.slice(0, limit)) {
      if (seenDocumentIds.has(documentMatch.documentId)) {
        continue;
      }

      contexts.push({
        rank: contexts.length + 1,
        relation: 'SIMILAR_DOCUMENT',
        documentId: documentMatch.documentId,
        caseFileId: documentMatch.caseFileId,
        caseInternalCode: documentMatch.caseInternalCode,
        caseTitle: documentMatch.caseTitle,
        processType: documentMatch.processType,
        status: documentMatch.status,
        originalName: documentMatch.originalName,
        fileType: documentMatch.fileType,
        ocrStatus: documentMatch.ocrStatus,
        score: documentMatch.score,
        snippet: documentMatch.snippet,
        matchReasons: documentMatch.matchReasons,
      });
      seenDocumentIds.add(documentMatch.documentId);
    }

    return contexts;
  }

  private buildSnippet(value: string | null | undefined): string | null {
    const normalizedValue = (value ?? '').replace(/\s+/g, ' ').trim();

    if (!normalizedValue) {
      return null;
    }

    if (normalizedValue.length <= 180) {
      return normalizedValue;
    }

    return `${normalizedValue.slice(0, 180).trim()}...`;
  }

  private normalizeLimit(limit: number | null | undefined): number {
    if (limit === null || limit === undefined || Number.isNaN(limit)) {
      return DEFAULT_LIMIT;
    }

    return Math.min(Math.max(Math.trunc(limit), 1), MAX_LIMIT);
  }
}
