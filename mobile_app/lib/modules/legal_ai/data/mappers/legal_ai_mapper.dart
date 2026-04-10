import '../../domain/entities/document_analysis_match.dart';
import '../../domain/entities/document_analysis_preview.dart';
import '../models/document_analysis_match_model.dart';
import '../models/document_analysis_preview_model.dart';

class LegalAiMapper {
  const LegalAiMapper._();

  static DocumentAnalysisPreview toDomain(
    DocumentAnalysisPreviewModel model,
  ) {
    return DocumentAnalysisPreview(
      mode: model.mode,
      summary: model.summary,
      sourceCaseFileId: model.sourceCaseFileId,
      sourceCaseInternalCode: model.sourceCaseInternalCode,
      sourceCaseSubject: model.sourceCaseSubject,
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
    );
  }

  static DocumentAnalysisMatch _matchToDomain(
    DocumentAnalysisMatchModel model,
  ) {
    return DocumentAnalysisMatch(
      caseFileId: model.caseFileId,
      internalCode: model.internalCode,
      subject: model.subject,
      processType: model.processType,
      status: model.status,
      score: model.score,
      matchReasons: model.matchReasons,
    );
  }
}
