import '../entities/document_analysis_preview.dart';

abstract class LegalAiRepository {
  Future<DocumentAnalysisPreview> getDocumentAnalysisPreview(String documentId);
}
