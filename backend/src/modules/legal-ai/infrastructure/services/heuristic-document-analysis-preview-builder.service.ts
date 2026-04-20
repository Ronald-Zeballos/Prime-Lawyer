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
        ? `Preview analysis found ${matches.length} potentially related cases using title, process type and document naming patterns.`
        : 'Preview analysis did not find strong metadata matches yet. Add more case files or richer case naming to improve early retrieval.',
      sourceCaseFile: {
        id: sourceCaseFile.id.value,
        internalCode: sourceCaseFile.internalCode,
        title: sourceCaseFile.title,
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
        `Source case: ${sourceCaseFile.internalCode}.`,
        `Case title detected from metadata: ${sourceCaseFile.title}.`,
        `Process type detected from metadata: ${sourceCaseFile.processType}.`,
        `Document is currently stored as ${sourceDocument.fileType.value} with OCR status ${sourceDocument.ocrStatus}.`,
      ],
      limitations: [
        'This preview does not read full PDF text yet.',
        'Similarity is based on metadata and naming patterns, not embeddings.',
        'Real semantic search will still require embeddings plus an AI provider configuration.',
      ],
      recommendedNextSteps: [
        'Keep uploading documents as PDF so the evidence trail stays reviewable.',
        sourceDocument.ocrStatus === 'COMPLETED'
          ? 'Reuse OCR text in the next sprint to improve retrieval and legal answers.'
          : 'Re-run OCR processing if the document still does not have searchable text.',
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
      `${sourceCaseFile.title} ${sourceCaseFile.processType} ${sourceDocumentName}`,
    );
    const candidateTokens = this.tokenize(
      `${candidateCaseFile.title} ${candidateCaseFile.processType} ${candidateCaseFile.internalCode}`,
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
      this.normalize(sourceCaseFile.title) ===
      this.normalize(candidateCaseFile.title)
    ) {
      score += 24;
      reasons.push('Very close case title.');
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
      title: candidateCaseFile.title,
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
