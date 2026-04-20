import { Inject, Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { ForbiddenError } from '../../../../../shared/application/errors/forbidden.error';
import { NotFoundError } from '../../../../../shared/application/errors/not-found.error';
import { UseCase } from '../../../../../shared/application/use-case';
import { DomainValidationError } from '../../../../../shared/domain/errors/domain-validation.error';
import { PrismaService } from '../../../../../shared/infrastructure/prisma/prisma.service';
import {
  SemanticSearchCaseMatchDto,
  SemanticSearchDocumentMatchDto,
  SemanticSearchDto,
} from '../../dto/semantic-search.dto';

const DEFAULT_LIMIT = 5;
const MAX_LIMIT = 10;

type SearchSemanticContentQuery = {
  requesterId: string;
  text?: string | null;
  processType?: string | null;
  caseFileId?: string | null;
  documentId?: string | null;
  limit?: number | null;
};

type SourceCaseFileRecord = Prisma.CaseFileGetPayload<{
  select: {
    id: true;
    ownerUserId: true;
    internalCode: true;
    title: true;
    description: true;
    processType: true;
    status: true;
  };
}>;

type SourceDocumentRecord = Prisma.DocumentGetPayload<{
  select: {
    id: true;
    caseFileId: true;
    originalName: true;
    fileType: true;
    ocrText: true;
    ocrStatus: true;
    caseFile: {
      select: {
        id: true;
        ownerUserId: true;
        internalCode: true;
        title: true;
        description: true;
        processType: true;
        status: true;
      };
    };
  };
}>;

type CandidateCaseFileRecord = Prisma.CaseFileGetPayload<{
  include: {
    documents: {
      select: {
        id: true;
        originalName: true;
        fileType: true;
        ocrStatus: true;
        ocrText: true;
        uploadedAt: true;
      };
    };
  };
}>;

type CandidateDocumentRecord = Prisma.DocumentGetPayload<{
  include: {
    caseFile: {
      select: {
        id: true;
        internalCode: true;
        ownerUserId: true;
        title: true;
        processType: true;
        status: true;
      };
    };
  };
}>;

type SearchContext = {
  normalizedText: string;
  normalizedProcessType: string;
  searchTokens: string[];
  sourceCaseFileId: string | null;
  sourceDocumentId: string | null;
  sourceCaseStatus: string | null;
  sourceCaseTitle: string | null;
  sourceDocumentFileType: string | null;
};

type ScoredCaseMatch = SemanticSearchCaseMatchDto & {
  updatedAt: Date;
};

type ScoredDocumentMatch = SemanticSearchDocumentMatchDto & {
  uploadedAt: Date;
};

@Injectable()
export class SearchSemanticContentUseCase
  implements UseCase<SearchSemanticContentQuery, SemanticSearchDto>
{
  constructor(private readonly prisma: PrismaService) {}

  async execute(query: SearchSemanticContentQuery): Promise<SemanticSearchDto> {
    const limit = this.normalizeLimit(query.limit);
    const sourceCaseFile = await this.resolveSourceCaseFile(
      query.caseFileId,
      query.requesterId,
    );
    const sourceDocument = await this.resolveSourceDocument(
      query.documentId,
      query.requesterId,
    );

    if (
      sourceCaseFile &&
      sourceDocument &&
      sourceDocument.caseFileId !== sourceCaseFile.id
    ) {
      throw new DomainValidationError(
        'The provided case file and document do not belong together.',
      );
    }

    const context = this.buildSearchContext({
      query,
      sourceCaseFile,
      sourceDocument,
      limit,
    });

    const candidateCaseFiles = await this.prisma.caseFile.findMany({
      where: {
        ownerUserId: query.requesterId,
        ...(context.sourceCaseFileId
          ? {
              id: {
                not: context.sourceCaseFileId,
              },
            }
          : {}),
      },
      include: {
        documents: {
          select: {
            id: true,
            originalName: true,
            fileType: true,
            ocrStatus: true,
            ocrText: true,
            uploadedAt: true,
          },
        },
      },
      orderBy: [{ updatedAt: 'desc' }],
      take: 100,
    });
    const candidateDocuments = await this.prisma.document.findMany({
      where: {
        caseFile: {
          is: {
            ownerUserId: query.requesterId,
          },
        },
        ...(context.sourceDocumentId
          ? {
              id: {
                not: context.sourceDocumentId,
              },
            }
          : {}),
      },
      include: {
        caseFile: {
          select: {
            id: true,
            internalCode: true,
            ownerUserId: true,
            title: true,
            processType: true,
            status: true,
          },
        },
      },
      orderBy: [{ uploadedAt: 'desc' }],
      take: 120,
    });

    const caseMatches = candidateCaseFiles
      .map((candidateCaseFile) => this.scoreCaseMatch(candidateCaseFile, context))
      .filter(
        (match): match is ScoredCaseMatch =>
          match !== null && match.score > 0,
      )
      .sort((left, right) => {
        if (right.score !== left.score) {
          return right.score - left.score;
        }

        return right.updatedAt.getTime() - left.updatedAt.getTime();
      })
      .slice(0, limit)
      .map(({ updatedAt, ...match }) => match);
    const documentMatches = candidateDocuments
      .map((candidateDocument) =>
        this.scoreDocumentMatch(candidateDocument, context),
      )
      .filter(
        (match): match is ScoredDocumentMatch =>
          match !== null && match.score > 0,
      )
      .sort((left, right) => {
        if (right.score !== left.score) {
          return right.score - left.score;
        }

        return right.uploadedAt.getTime() - left.uploadedAt.getTime();
      })
      .slice(0, limit)
      .map(({ uploadedAt, ...match }) => match);

    return {
      mode: 'HEURISTIC',
      query: {
        text: context.normalizedText || null,
        processType: context.normalizedProcessType || null,
        caseFileId: query.caseFileId?.trim() || null,
        documentId: query.documentId?.trim() || null,
        limit,
      },
      caseMatches,
      documentMatches,
    };
  }

  private async resolveSourceCaseFile(
    caseFileId: string | null | undefined,
    requesterId: string,
  ): Promise<SourceCaseFileRecord | null> {
    const normalizedCaseFileId = caseFileId?.trim();

    if (!normalizedCaseFileId) {
      return null;
    }

    const caseFile = await this.prisma.caseFile.findUnique({
      where: { id: normalizedCaseFileId },
      select: {
        id: true,
        ownerUserId: true,
        internalCode: true,
        title: true,
        description: true,
        processType: true,
        status: true,
      },
    });

    if (!caseFile) {
      throw new NotFoundError('Source case file was not found.');
    }

    if (caseFile.ownerUserId !== requesterId.trim()) {
      throw new ForbiddenError(
        'This case file is not available for the current user.',
      );
    }

    return caseFile;
  }

  private async resolveSourceDocument(
    documentId: string | null | undefined,
    requesterId: string,
  ): Promise<SourceDocumentRecord | null> {
    const normalizedDocumentId = documentId?.trim();

    if (!normalizedDocumentId) {
      return null;
    }

    const document = await this.prisma.document.findUnique({
      where: { id: normalizedDocumentId },
      select: {
        id: true,
        caseFileId: true,
        originalName: true,
        fileType: true,
        ocrText: true,
        ocrStatus: true,
        caseFile: {
          select: {
            id: true,
            ownerUserId: true,
            internalCode: true,
            title: true,
            description: true,
            processType: true,
            status: true,
          },
        },
      },
    });

    if (!document) {
      throw new NotFoundError('Source document was not found.');
    }

    if (document.caseFile.ownerUserId !== requesterId.trim()) {
      throw new ForbiddenError(
        'This document is not available for the current user.',
      );
    }

    return document;
  }

  private buildSearchContext(params: {
    query: SearchSemanticContentQuery;
    sourceCaseFile: SourceCaseFileRecord | null;
    sourceDocument: SourceDocumentRecord | null;
    limit: number;
  }): SearchContext {
    const sourceCaseFile = params.sourceCaseFile ?? params.sourceDocument?.caseFile;
    const searchText = [
      params.query.text?.trim() ?? '',
      sourceCaseFile?.title ?? '',
      sourceCaseFile?.description ?? '',
      sourceCaseFile?.processType ?? '',
      params.sourceDocument?.originalName ?? '',
      params.sourceDocument?.ocrText ?? '',
    ]
      .map((value) => value.trim())
      .filter((value) => value.length > 0)
      .join(' ');
    const normalizedText = this.normalize(searchText);
    const normalizedProcessType = this.normalize(
      params.query.processType?.trim() ??
        sourceCaseFile?.processType ??
        '',
    );

    if (!normalizedText && !normalizedProcessType) {
      throw new DomainValidationError(
        'Provide a text query, a process type, or a source case/document to search from.',
      );
    }

    return {
      normalizedText,
      normalizedProcessType,
      searchTokens: this.tokenize(searchText),
      sourceCaseFileId: sourceCaseFile?.id ?? null,
      sourceDocumentId: params.sourceDocument?.id ?? null,
      sourceCaseStatus: sourceCaseFile?.status ?? null,
      sourceCaseTitle: sourceCaseFile?.title ?? null,
      sourceDocumentFileType: params.sourceDocument?.fileType ?? null,
    };
  }

  private scoreCaseMatch(
    candidateCaseFile: CandidateCaseFileRecord,
    context: SearchContext,
  ): ScoredCaseMatch | null {
    const caseCorpus = this.buildCaseCorpus(candidateCaseFile);
    const caseTokens = this.tokenize(caseCorpus);
    const sharedTokens = context.searchTokens.filter((token) =>
      caseTokens.includes(token),
    );
    const reasons: string[] = [];
    let score = 0;
    let hasPrimarySignal = false;

    if (
      context.normalizedProcessType &&
      this.normalize(candidateCaseFile.processType) ===
        context.normalizedProcessType
    ) {
      score += 32;
      hasPrimarySignal = true;
      reasons.push(`Same process type: ${candidateCaseFile.processType}.`);
    } else if (
      context.normalizedProcessType &&
      this.normalize(candidateCaseFile.processType).includes(
        context.normalizedProcessType,
      )
    ) {
      score += 18;
      hasPrimarySignal = true;
      reasons.push(
        `Related process type: ${candidateCaseFile.processType}.`,
      );
    }

    if (
      context.normalizedText &&
      this.normalize(caseCorpus).includes(context.normalizedText) &&
      context.normalizedText.length >= 4
    ) {
      score += 24;
      hasPrimarySignal = true;
      reasons.push('Strong text match across case metadata.');
    }

    if (sharedTokens.length > 0) {
      score += Math.min(48, sharedTokens.length * 8);
      hasPrimarySignal = true;
      reasons.push(
        `Shared keywords: ${sharedTokens.slice(0, 5).join(', ')}.`,
      );
    }

    const matchedDocumentCount = candidateCaseFile.documents.filter((document) =>
      this.documentMatchesTokens(document, context.searchTokens),
    ).length;

    if (matchedDocumentCount > 0) {
      score += Math.min(18, matchedDocumentCount * 6);
      hasPrimarySignal = true;
      reasons.push(
        `Matched supporting documents: ${matchedDocumentCount}.`,
      );
    }

    if (
      context.sourceCaseStatus &&
      candidateCaseFile.status === context.sourceCaseStatus
    ) {
      score += 6;
      reasons.push(`Same case status: ${candidateCaseFile.status}.`);
    }

    if (
      candidateCaseFile.knowledgeStatus === 'ELIGIBLE' ||
      candidateCaseFile.knowledgeStatus === 'PUBLISHED'
    ) {
      score += 4;
    }

    if (
      candidateCaseFile.documents.some(
        (document) =>
          document.ocrStatus === 'COMPLETED' &&
          (document.ocrText?.trim().length ?? 0) > 0,
      )
    ) {
      score += 4;
      reasons.push('Includes searchable OCR text.');
    }

    if (score <= 0 || !hasPrimarySignal) {
      return null;
    }

    const snippet =
      this.buildSnippet(
        candidateCaseFile.documents
          .map((document) => document.ocrText ?? '')
          .find((value) => value.trim().length > 0) ??
          candidateCaseFile.description ??
          candidateCaseFile.title,
        context.searchTokens,
      ) ?? null;

    return {
      caseFileId: candidateCaseFile.id,
      internalCode: candidateCaseFile.internalCode,
      title: candidateCaseFile.title,
      processType: candidateCaseFile.processType,
      status: candidateCaseFile.status,
      visibility: candidateCaseFile.visibility,
      knowledgeStatus: candidateCaseFile.knowledgeStatus,
      score,
      matchedDocumentCount,
      snippet,
      matchReasons: reasons.slice(0, 4),
      updatedAt: candidateCaseFile.updatedAt,
    };
  }

  private scoreDocumentMatch(
    candidateDocument: CandidateDocumentRecord,
    context: SearchContext,
  ): ScoredDocumentMatch | null {
    const documentCorpus = this.buildDocumentCorpus(candidateDocument);
    const documentTokens = this.tokenize(documentCorpus);
    const sharedTokens = context.searchTokens.filter((token) =>
      documentTokens.includes(token),
    );
    const reasons: string[] = [];
    let score = 0;
    let hasPrimarySignal = false;

    if (
      context.normalizedProcessType &&
      this.normalize(candidateDocument.caseFile.processType) ===
        context.normalizedProcessType
    ) {
      score += 28;
      hasPrimarySignal = true;
      reasons.push(
        `Same process type: ${candidateDocument.caseFile.processType}.`,
      );
    }

    if (
      context.sourceDocumentFileType &&
      this.normalize(candidateDocument.fileType) ===
        this.normalize(context.sourceDocumentFileType)
    ) {
      score += 8;
      reasons.push(`Same file type: ${candidateDocument.fileType}.`);
    }

    if (
      context.normalizedText &&
      this.normalize(documentCorpus).includes(context.normalizedText) &&
      context.normalizedText.length >= 4
    ) {
      score += 22;
      hasPrimarySignal = true;
      reasons.push('Strong text match inside document metadata or OCR.');
    }

    if (sharedTokens.length > 0) {
      score += Math.min(50, sharedTokens.length * 10);
      hasPrimarySignal = true;
      reasons.push(
        `Shared keywords: ${sharedTokens.slice(0, 5).join(', ')}.`,
      );
    }

    if (
      candidateDocument.ocrStatus === 'COMPLETED' &&
      (candidateDocument.ocrText?.trim().length ?? 0) > 0
    ) {
      score += 6;
      reasons.push('Document already has OCR text.');
    }

    if (
      context.sourceCaseTitle &&
      this.normalize(candidateDocument.caseFile.title) ===
        this.normalize(context.sourceCaseTitle)
    ) {
      score += 6;
      hasPrimarySignal = true;
    }

    if (
      context.sourceCaseStatus &&
      candidateDocument.caseFile.status === context.sourceCaseStatus
    ) {
      score += 4;
    }

    if (score <= 0 || !hasPrimarySignal) {
      return null;
    }

    return {
      documentId: candidateDocument.id,
      caseFileId: candidateDocument.caseFileId,
      caseInternalCode: candidateDocument.caseFile.internalCode,
      caseTitle: candidateDocument.caseFile.title,
      processType: candidateDocument.caseFile.processType,
      status: candidateDocument.caseFile.status,
      originalName: candidateDocument.originalName,
      fileType: candidateDocument.fileType,
      ocrStatus: candidateDocument.ocrStatus,
      score,
      snippet:
        this.buildSnippet(
          candidateDocument.ocrText ??
            `${candidateDocument.originalName} ${candidateDocument.caseFile.title}`,
          context.searchTokens,
        ) ?? null,
      matchReasons: reasons.slice(0, 4),
      uploadedAt: candidateDocument.uploadedAt,
    };
  }

  private buildCaseCorpus(candidateCaseFile: CandidateCaseFileRecord): string {
    const documentCorpus = candidateCaseFile.documents
      .map((document) =>
        [document.originalName, (document.ocrText ?? '').slice(0, 600)]
          .map((value) => value.trim())
          .filter((value) => value.length > 0)
          .join(' '),
      )
      .join(' ');

    return [
      candidateCaseFile.internalCode,
      candidateCaseFile.title,
      candidateCaseFile.description ?? '',
      candidateCaseFile.processType,
      documentCorpus,
    ]
      .map((value) => value.trim())
      .filter((value) => value.length > 0)
      .join(' ');
  }

  private buildDocumentCorpus(candidateDocument: CandidateDocumentRecord): string {
    return [
      candidateDocument.originalName,
      candidateDocument.caseFile.internalCode,
      candidateDocument.caseFile.title,
      candidateDocument.caseFile.processType,
      candidateDocument.ocrText ?? '',
    ]
      .map((value) => value.trim())
      .filter((value) => value.length > 0)
      .join(' ');
  }

  private documentMatchesTokens(
    document: CandidateCaseFileRecord['documents'][number],
    searchTokens: string[],
  ): boolean {
    if (searchTokens.length === 0) {
      return false;
    }

    const documentCorpus = this.normalize(
      `${document.originalName} ${document.ocrText ?? ''}`,
    );

    return searchTokens.some(
      (token) => token.length >= 3 && documentCorpus.includes(token),
    );
  }

  private buildSnippet(
    sourceText: string | null | undefined,
    searchTokens: string[],
  ): string | null {
    const normalizedText = sourceText?.replace(/\s+/g, ' ').trim();

    if (!normalizedText) {
      return null;
    }

    const normalizedLower = normalizedText.toLowerCase();

    for (const token of searchTokens) {
      if (token.length < 4) {
        continue;
      }

      const matchIndex = normalizedLower.indexOf(token);

      if (matchIndex < 0) {
        continue;
      }

      const startIndex = Math.max(0, matchIndex - 60);
      const endIndex = Math.min(normalizedText.length, matchIndex + 140);
      const prefix = startIndex > 0 ? '...' : '';
      const suffix = endIndex < normalizedText.length ? '...' : '';

      return `${prefix}${normalizedText.slice(startIndex, endIndex).trim()}${suffix}`;
    }

    if (normalizedText.length <= 180) {
      return normalizedText;
    }

    return `${normalizedText.slice(0, 180).trim()}...`;
  }

  private tokenize(value: string): string[] {
    const stopWords = new Set([
      'the',
      'and',
      'for',
      'with',
      'that',
      'this',
      'from',
      'para',
      'con',
      'por',
      'del',
      'las',
      'los',
      'una',
      'uno',
      'sobre',
      'same',
      'source',
      'provided',
      'explicit',
      'consultation',
      'open',
      'private',
      'draft',
      'caso',
      'case',
      'file',
      'document',
      'documento',
      'mvp',
      'test',
      'ocr',
    ]);

    return [...new Set(
      value
        .toLowerCase()
        .replace(/[^a-z0-9\s]/g, ' ')
        .split(/\s+/)
        .map((token) => token.trim())
        .filter(
          (token) =>
            token.length >= 3 &&
            !stopWords.has(token) &&
            !/\d/.test(token),
        ),
    )];
  }

  private normalize(value: string | null | undefined): string {
    return (value ?? '').trim().toLowerCase().replace(/\s+/g, ' ');
  }

  private normalizeLimit(limit: number | null | undefined): number {
    if (limit === null || limit === undefined || Number.isNaN(limit)) {
      return DEFAULT_LIMIT;
    }

    return Math.min(Math.max(Math.trunc(limit), 1), MAX_LIMIT);
  }
}
