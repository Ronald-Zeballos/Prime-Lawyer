import '../entities/document_file.dart';
import '../repositories/document_repository.dart';

class GetDocumentFileUseCase {
  const GetDocumentFileUseCase(this._documentRepository);

  final DocumentRepository _documentRepository;

  Future<DocumentFile> execute({
    required String documentId,
    required String fileName,
    required String fileType,
  }) {
    return _documentRepository.getDocumentFile(
      documentId: documentId,
      fileName: fileName,
      fileType: fileType,
    );
  }
}
