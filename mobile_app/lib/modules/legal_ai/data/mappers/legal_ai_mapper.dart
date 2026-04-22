import '../../domain/entities/contextual_legal_answer.dart';
import '../../domain/entities/document_analysis_document_match.dart';
import '../models/contextual_legal_answer_model.dart';
import '../../domain/entities/document_analysis_match.dart';
import '../../domain/entities/document_analysis_preview.dart';
import '../models/document_analysis_document_match_model.dart';
import '../models/document_analysis_match_model.dart';
import '../models/document_analysis_preview_model.dart';

class LegalAiMapper {
  const LegalAiMapper._();

  static ContextualLegalAnswer contextualAnswerToDomain(
    ContextualLegalAnswerModel model,
  ) {
    return ContextualLegalAnswer(
      queryId: model.queryId,
      mode: model.mode,
      question: model.question,
      sourceCaseFile: model.sourceCaseFile == null
          ? null
          : LegalAiSourceCaseFile(
              id: model.sourceCaseFile!.id,
              internalCode: model.sourceCaseFile!.internalCode,
              title: model.sourceCaseFile!.title,
              descriptionSnippet: model.sourceCaseFile!.descriptionSnippet,
              processType: model.sourceCaseFile!.processType,
              status: model.sourceCaseFile!.status,
              visibility: model.sourceCaseFile!.visibility,
              knowledgeStatus: model.sourceCaseFile!.knowledgeStatus,
            ),
      sourceDocument: model.sourceDocument == null
          ? null
          : LegalAiSourceDocument(
              id: model.sourceDocument!.id,
              caseFileId: model.sourceDocument!.caseFileId,
              originalName: model.sourceDocument!.originalName,
              fileType: model.sourceDocument!.fileType,
              ocrStatus: model.sourceDocument!.ocrStatus,
              uploadSource: model.sourceDocument!.uploadSource,
              snippet: model.sourceDocument!.snippet,
            ),
      usedContextCases: model.usedContextCases
          .map(
            (item) => LegalAiContextCase(
              rank: item.rank,
              relation: item.relation,
              caseFileId: item.caseFileId,
              internalCode: item.internalCode,
              title: item.title,
              processType: item.processType,
              status: item.status,
              visibility: item.visibility,
              knowledgeStatus: item.knowledgeStatus,
              score: item.score,
              snippet: item.snippet,
              matchReasons: item.matchReasons,
            ),
          )
          .toList(),
      usedContextDocuments: model.usedContextDocuments
          .map(
            (item) => LegalAiContextDocument(
              rank: item.rank,
              relation: item.relation,
              documentId: item.documentId,
              caseFileId: item.caseFileId,
              caseInternalCode: item.caseInternalCode,
              caseTitle: item.caseTitle,
              processType: item.processType,
              status: item.status,
              originalName: item.originalName,
              fileType: item.fileType,
              ocrStatus: item.ocrStatus,
              score: item.score,
              snippet: item.snippet,
              matchReasons: item.matchReasons,
            ),
          )
          .toList(),
      createdAt: model.createdAt,
      language: model.language,
      groundingStatus: model.groundingStatus,
      answer: model.answer,
      disclaimer: model.disclaimer,
      limitations: model.limitations,
      recommendedNextSteps: model.recommendedNextSteps,
      followUpQuestions: model.followUpQuestions,
    );
  }

  static DocumentAnalysisPreview toDomain(
    DocumentAnalysisPreviewModel model,
  ) {
    return DocumentAnalysisPreview(
      mode: model.mode,
      summary: model.summary,
      sourceCaseFileId: model.sourceCaseFileId,
      sourceCaseInternalCode: model.sourceCaseInternalCode,
      sourceCaseTitle: model.sourceCaseTitle,
      sourceProcessType: model.sourceProcessType,
      sourceStatus: model.sourceStatus,
      sourceConfidentialityLevel: model.sourceConfidentialityLevel,
      sourceDocumentId: model.sourceDocumentId,
      sourceDocumentName: model.sourceDocumentName,
      sourceDocumentType: model.sourceDocumentType,
      sourceDocumentOcrStatus: model.sourceDocumentOcrStatus,
      sourceUploadSource: model.sourceUploadSource,
      highlights: model.highlights,
      limitations: model.limitations,
      recommendedNextSteps: model.recommendedNextSteps,
      matches: model.matches.map(_matchToDomain).toList(),
      documentMatches:
          model.documentMatches.map(_documentMatchToDomain).toList(),
    );
  }

  static DocumentAnalysisMatch _matchToDomain(
    DocumentAnalysisMatchModel model,
  ) {
    return DocumentAnalysisMatch(
      caseFileId: model.caseFileId,
      internalCode: model.internalCode,
      title: model.title,
      processType: model.processType,
      status: model.status,
      visibility: model.visibility,
      knowledgeStatus: model.knowledgeStatus,
      score: model.score,
      matchedDocumentCount: model.matchedDocumentCount,
      snippet: model.snippet,
      matchReasons: model.matchReasons,
    );
  }

  static DocumentAnalysisDocumentMatch _documentMatchToDomain(
    DocumentAnalysisDocumentMatchModel model,
  ) {
    return DocumentAnalysisDocumentMatch(
      documentId: model.documentId,
      caseFileId: model.caseFileId,
      caseInternalCode: model.caseInternalCode,
      caseTitle: model.caseTitle,
      processType: model.processType,
      status: model.status,
      originalName: model.originalName,
      fileType: model.fileType,
      ocrStatus: model.ocrStatus,
      score: model.score,
      snippet: model.snippet,
      matchReasons: model.matchReasons,
    );
  }
}
