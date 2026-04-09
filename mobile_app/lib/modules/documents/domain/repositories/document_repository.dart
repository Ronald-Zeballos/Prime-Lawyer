import '../../../document_capture/domain/entities/captured_document.dart';
import '../entities/document.dart';

class RegisterDocumentInput {
  const RegisterDocumentInput({
    required this.caseFileId,
    required this.document,
    this.uploadSource = 'mobile_app',
  });

  final String caseFileId;
  final CapturedDocument document;
  final String uploadSource;
}

abstract class DocumentRepository {
  Future<List<Document>> getCaseDocuments(String caseFileId);

  Future<Document> registerDocument(RegisterDocumentInput input);
}
