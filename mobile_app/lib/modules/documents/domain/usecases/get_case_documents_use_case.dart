import '../entities/document.dart';
import '../repositories/document_repository.dart';

class GetCaseDocumentsUseCase {
  const GetCaseDocumentsUseCase(this._documentRepository);

  final DocumentRepository _documentRepository;

  Future<List<Document>> execute(String caseFileId) {
    return _documentRepository.getCaseDocuments(caseFileId);
  }
}
