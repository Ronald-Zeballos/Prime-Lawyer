import { Injectable } from '@nestjs/common';
import {
  BuildDocumentAnalysisPreviewCommand,
  DocumentAnalysisPreviewBuilder,
} from '../../application/ports/document-analysis-preview-builder.port';
import {
  DocumentAnalysisPreviewDto,
  DocumentAnalysisPreviewDocumentMatchDto,
  DocumentAnalysisPreviewMatchDto,
} from '../../application/dto/document-analysis-preview.dto';

@Injectable()
export class HeuristicDocumentAnalysisPreviewBuilderService
  implements DocumentAnalysisPreviewBuilder
{
  build(
    command: BuildDocumentAnalysisPreviewCommand,
  ): DocumentAnalysisPreviewDto {
    const { sourceCaseFile, sourceDocument, semanticSearch } = command;
    const matches = semanticSearch.caseMatches.map(
      (match): DocumentAnalysisPreviewMatchDto => ({
        caseFileId: match.caseFileId,
        internalCode: match.internalCode,
        title: match.title,
        processType: match.processType,
        status: match.status,
        visibility: match.visibility,
        knowledgeStatus: match.knowledgeStatus,
        score: match.score,
        matchedDocumentCount: match.matchedDocumentCount,
        snippet: match.snippet,
        matchReasons: match.matchReasons,
      }),
    );
    const documentMatches = semanticSearch.documentMatches.map(
      (match): DocumentAnalysisPreviewDocumentMatchDto => ({
        documentId: match.documentId,
        caseFileId: match.caseFileId,
        caseInternalCode: match.caseInternalCode,
        caseTitle: match.caseTitle,
        processType: match.processType,
        status: match.status,
        originalName: match.originalName,
        fileType: match.fileType,
        ocrStatus: match.ocrStatus,
        score: match.score,
        snippet: match.snippet,
        matchReasons: match.matchReasons,
      }),
    );
    const sourceHasSearchableText =
      (sourceDocument.ocrText?.trim().length ?? 0) > 0;
    const strongestCaseMatch = matches.length === 0 ? null : matches[0];
    const strongestDocumentMatch = documentMatches.length === 0
      ? null
      : documentMatches[0];
    const summary = this.buildSummary({
      sourceDocumentName: sourceDocument.originalName,
      caseMatchesCount: matches.length,
      documentMatchesCount: documentMatches.length,
      sourceHasSearchableText,
    });

    return {
      mode: 'PREVIEW',
      summary,
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
      highlights: this.buildHighlights({
        sourceCaseFile: sourceCaseFile.internalCode,
        sourceCaseTitle: sourceCaseFile.title,
        sourceProcessType: sourceCaseFile.processType,
        sourceDocumentName: sourceDocument.originalName,
        sourceDocumentType: sourceDocument.fileType.value,
        sourceDocumentOcrStatus: sourceDocument.ocrStatus,
        sourceHasSearchableText,
        strongestCaseMatch,
        strongestDocumentMatch,
        documentMatchesCount: documentMatches.length,
      }),
      limitations: [
        sourceHasSearchableText
          ? 'This preview uses heuristic retrieval over metadata plus available OCR text, not a full legal reading of every clause.'
          : 'The document does not expose usable OCR text yet, so matching leans more heavily on case metadata and file naming.',
        'Similarity is still heuristic and does not use embeddings or jurisprudential ranking yet.',
        'This preview accelerates review, but it does not replace a lawyer validating the cited matches and source PDFs.',
      ],
      recommendedNextSteps: this.buildRecommendedNextSteps({
        sourceDocumentName: sourceDocument.originalName,
        sourceDocumentOcrStatus: sourceDocument.ocrStatus,
        strongestCaseMatch,
        strongestDocumentMatch,
      }),
      matches,
      documentMatches,
    };
  }

  private buildSummary(params: {
    sourceDocumentName: string;
    caseMatchesCount: number;
    documentMatchesCount: number;
    sourceHasSearchableText: boolean;
  }): string {
    const retrievalMode = params.sourceHasSearchableText
      ? 'metadata plus OCR-backed retrieval'
      : 'metadata-first retrieval';

    if (params.caseMatchesCount > 0 || params.documentMatchesCount > 0) {
      return `Preview analysis for ${params.sourceDocumentName} found ${params.caseMatchesCount} related case files and ${params.documentMatchesCount} supporting documents using ${retrievalMode}.`;
    }

    return `Preview analysis for ${params.sourceDocumentName} did not find strong related cases yet. Add more closed matters, richer case descriptions, or searchable OCR text to strengthen retrieval.`;
  }

  private buildHighlights(params: {
    sourceCaseFile: string;
    sourceCaseTitle: string;
    sourceProcessType: string;
    sourceDocumentName: string;
    sourceDocumentType: string;
    sourceDocumentOcrStatus: string;
    sourceHasSearchableText: boolean;
    strongestCaseMatch: DocumentAnalysisPreviewMatchDto | null;
    strongestDocumentMatch: DocumentAnalysisPreviewDocumentMatchDto | null;
    documentMatchesCount: number;
  }): string[] {
    const items = [
      `Source case ${params.sourceCaseFile} keeps the analysis anchored to ${params.sourceCaseTitle}.`,
      `Process type detected for retrieval: ${params.sourceProcessType}.`,
      `Source document ${params.sourceDocumentName} is stored as ${params.sourceDocumentType} with OCR status ${params.sourceDocumentOcrStatus}.`,
      params.sourceHasSearchableText
        ? 'Searchable OCR text was available and used to enrich document-level matching.'
        : 'The preview had to rely mostly on metadata because searchable OCR text is still limited.',
    ];

    if (params.strongestCaseMatch != null) {
      items.push(
        `Strongest related case: ${params.strongestCaseMatch.internalCode} with score ${params.strongestCaseMatch.score}.`,
      );
    }

    if (params.strongestDocumentMatch != null) {
      items.push(
        `Best supporting document match: ${params.strongestDocumentMatch.originalName} inside ${params.strongestDocumentMatch.caseInternalCode}.`,
      );
    } else if (params.documentMatchesCount === 0) {
      items.push(
        'No supporting document matches were strong enough to surface yet.',
      );
    }

    return items;
  }

  private buildRecommendedNextSteps(params: {
    sourceDocumentName: string;
    sourceDocumentOcrStatus: string;
    strongestCaseMatch: DocumentAnalysisPreviewMatchDto | null;
    strongestDocumentMatch: DocumentAnalysisPreviewDocumentMatchDto | null;
  }): string[] {
    const items: string[] = [];

    if (params.strongestCaseMatch != null) {
      items.push(
        `Open ${params.strongestCaseMatch.internalCode} first and verify the reasons surfaced by the preview.`,
      );
    }

    if (params.strongestDocumentMatch != null) {
      items.push(
        `Review ${params.strongestDocumentMatch.originalName} to contrast clauses, facts, or document structure against ${params.sourceDocumentName}.`,
      );
    }

    items.push(
      params.sourceDocumentOcrStatus === 'COMPLETED'
        ? 'Reuse this grounded context in the contextual legal consultation to ask for a tighter legal summary.'
        : 'Re-run OCR if possible so future previews and legal answers can use searchable text instead of filename metadata alone.',
    );

    return items;
  }
}
