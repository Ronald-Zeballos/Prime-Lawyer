import '../entities/contextual_legal_answer.dart';
import '../entities/document_analysis_preview.dart';

abstract class LegalAiRepository {
  Future<DocumentAnalysisPreview> getDocumentAnalysisPreview(String documentId);

  Future<ContextualLegalAnswer> askContextualQuestion({
    required String question,
    String? caseFileId,
    String? documentId,
    String? processType,
    int limit = 3,
  });
}
