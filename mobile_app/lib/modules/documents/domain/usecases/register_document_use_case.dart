import '../entities/document.dart';
import '../repositories/document_repository.dart';

class RegisterDocumentUseCase {
  const RegisterDocumentUseCase(this._documentRepository);

  final DocumentRepository _documentRepository;

  Future<Document> execute(RegisterDocumentInput input) {
    return _documentRepository.registerDocument(input);
  }
}
