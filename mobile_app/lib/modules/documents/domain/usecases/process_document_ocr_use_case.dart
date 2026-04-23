import '../entities/document.dart';
import '../repositories/document_repository.dart';

class ProcessDocumentOcrUseCase {
  const ProcessDocumentOcrUseCase(this._documentRepository);

  final DocumentRepository _documentRepository;

  Future<Document> execute(String documentId) {
    return _documentRepository.processDocumentOcr(documentId);
  }
}
