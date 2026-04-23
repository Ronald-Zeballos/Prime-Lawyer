import '../entities/document_scan_draft.dart';
import '../repositories/document_capture_repository.dart';

class StartDocumentScanUseCase {
  const StartDocumentScanUseCase(this._documentCaptureRepository);

  final DocumentCaptureRepository _documentCaptureRepository;

  Future<DocumentScanDraft?> execute() {
    return _documentCaptureRepository.scanDocument();
  }
}
