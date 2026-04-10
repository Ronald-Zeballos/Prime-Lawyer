import { Injectable } from '@nestjs/common';
import {
  BuildDocumentAnalysisPreviewCommand,
  DocumentAnalysisPreviewBuilder,
} from '../../application/ports/document-analysis-preview-builder.port';
import {
  DocumentAnalysisPreviewDto,
  DocumentAnalysisPreviewMatchDto,
} from '../../application/dto/document-analysis-preview.dto';

@Injectable()
export class HeuristicDocumentAnalysisPreviewBuilderService
  implements DocumentAnalysisPreviewBuilder
{
  build(
    command: BuildDocumentAnalysisPreviewCommand,
  ): DocumentAnalysisPreviewDto {
    const { sourceCaseFile, sourceDocument, candidateCaseFiles } = command;
    const matches = candidateCaseFiles
      .map((candidateCaseFile) =>
        this.buildMatch(sourceCaseFile, sourceDocument.originalName, candidateCaseFile),
      )
      .filter(
        (match): match is DocumentAnalysisPreviewMatchDto => match !== null,
      )
      .sort((left, right) => right.score - left.score)
      .slice(0, 5);

    return {
      mode: 'PREVIEW',
      summary: matches.length > 0
        ? `Preview analysis found ${matches.length} potentially related case files using matter, process type and document naming patterns.`
        : 'Preview analysis did not find strong metadata matches yet. Add more case files or richer case naming to improve early retrieval.',
      sourceCaseFile: {
        id: sourceCaseFile.id.value,
        internalCode: sourceCaseFile.internalCode,
        subject: sourceCaseFile.subject,
        processType: sourceCaseFile.processType,
        status: sourceCaseFile.status.value,
        confidentialityLevel: sourceCaseFile.confidentialityLevel.value,
      },
      sourceDocument: {
        id: sourceDocument.id.value,
        originalName: sourceDocument.originalName,
        fileType: sourceDocument.fileType.value,
        ocrStatus: sourceDocument.ocrStatus,
        uploadSource: sourceDocument.uploadSource,
      },
      highlights: [
        `Source case file: ${sourceCaseFile.internalCode}.`,
        `Main matter detected from metadata: ${sourceCaseFile.subject}.`,
        `Process type detected from metadata: ${sourceCaseFile.processType}.`,
        `Document is currently stored as ${sourceDocument.fileType.value} with OCR status ${sourceDocument.ocrStatus}.`,
      ],
      limitations: [
        'This preview does not read full PDF text yet.',
        'Similarity is based on metadata and naming patterns, not embeddings.',
        'Real semantic search will require OCR text extraction plus an AI provider configuration.',
      ],
      recommendedNextSteps: [
        'Keep uploading documents as PDF so the evidence trail stays reviewable.',
        'Enable OCR processing to extract searchable text from each document.',
        'Connect OpenAI embeddings later to move from metadata similarity to semantic retrieval.',
      ],
      matches,
    };
  }

  private buildMatch(
    sourceCaseFile: BuildDocumentAnalysisPreviewCommand['sourceCaseFile'],
    sourceDocumentName: string,
    candidateCaseFile: BuildDocumentAnalysisPreviewCommand['candidateCaseFiles'][number],
  ): DocumentAnalysisPreviewMatchDto | null {
    const sourceTokens = this.tokenize(
      `${sourceCaseFile.subject} ${sourceCaseFile.processType} ${sourceDocumentName}`,
    );
    const candidateTokens = this.tokenize(
      `${candidateCaseFile.subject} ${candidateCaseFile.processType} ${candidateCaseFile.internalCode}`,
    );
    const sharedTokens = [...sourceTokens].filter((token) =>
      candidateTokens.has(token),
    );
    const reasons: string[] = [];
    let score = sharedTokens.length * 14;

    if (
      this.normalize(sourceCaseFile.processType) ===
      this.normalize(candidateCaseFile.processType)
    ) {
      score += 35;
      reasons.push(`Same process type: ${candidateCaseFile.processType}.`);
    }

    if (
      this.normalize(sourceCaseFile.subject) ===
      this.normalize(candidateCaseFile.subject)
    ) {
      score += 24;
      reasons.push('Very close matter label.');
    }

    if (sharedTokens.length > 0) {
      reasons.push(
        `Shared keywords: ${sharedTokens.slice(0, 4).join(', ')}.`,
      );
    }

    if (sourceCaseFile.status.value === candidateCaseFile.status.value) {
      score += 8;
      reasons.push(`Same status: ${this.humanizeEnum(candidateCaseFile.status.value)}.`);
    }

    if (
      sourceCaseFile.confidentialityLevel.value ===
      candidateCaseFile.confidentialityLevel.value
    ) {
      score += 4;
      reasons.push(
        `Same confidentiality level: ${this.humanizeEnum(candidateCaseFile.confidentialityLevel.value)}.`,
      );
    }

    if (score <= 0 || reasons.length === 0) {
      return null;
    }

    return {
      caseFileId: candidateCaseFile.id.value,
      internalCode: candidateCaseFile.internalCode,
      subject: candidateCaseFile.subject,
      processType: candidateCaseFile.processType,
      status: candidateCaseFile.status.value,
      score,
      matchReasons: reasons.slice(0, 3),
    };
  }

  private tokenize(value: string): Set<string> {
    const stopWords = new Set([
      'the',
      'and',
      'for',
      'con',
      'para',
      'del',
      'las',
      'los',
      'caso',
      'case',
      'file',
      'document',
      'expediente',
      'documento',
    ]);

    return new Set(
      value
        .toLowerCase()
        .replace(/[^a-z0-9\s]/g, ' ')
        .split(/\s+/)
        .map((token) => token.trim())
        .filter((token) => token.length >= 3 && !stopWords.has(token)),
    );
  }

  private normalize(value: string): string {
    return value.trim().toLowerCase().replace(/\s+/g, ' ');
  }

  private humanizeEnum(value: string): string {
    return value
      .toLowerCase()
      .split('_')
      .map((segment) => `${segment[0]?.toUpperCase() ?? ''}${segment.slice(1)}`)
      .join(' ');
  }
}
