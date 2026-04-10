import '../entities/document_analysis_preview.dart';
import '../repositories/legal_ai_repository.dart';

class GetDocumentAnalysisPreviewUseCase {
  const GetDocumentAnalysisPreviewUseCase(this._legalAiRepository);

  final LegalAiRepository _legalAiRepository;

  Future<DocumentAnalysisPreview> execute(String documentId) {
    return _legalAiRepository.getDocumentAnalysisPreview(documentId);
  }
}
