import '../entities/captured_document.dart';
import '../entities/document_scan_draft.dart';
import '../repositories/document_capture_repository.dart';

class ProcessScannedDocumentUseCase {
  const ProcessScannedDocumentUseCase(this._documentCaptureRepository);

  final DocumentCaptureRepository _documentCaptureRepository;

  Future<CapturedDocument> execute(
    DocumentScanDraft draft, {
    String? fileName,
    DocumentCaptureProgressCallback? onProgress,
  }) {
    return _documentCaptureRepository.processScannedDocument(
      draft,
      fileName: fileName,
      onProgress: onProgress,
    );
  }
}
