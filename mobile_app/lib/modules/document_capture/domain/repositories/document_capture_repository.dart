import '../entities/captured_document.dart';
import '../entities/document_capture_progress.dart';
import '../entities/document_scan_draft.dart';

typedef DocumentCaptureProgressCallback = void Function(
  DocumentCaptureProgress progress,
);

abstract class DocumentCaptureRepository {
  Future<CapturedDocument?> pickDocument();

  Future<CapturedDocument?> captureFromCamera();

  Future<DocumentScanDraft?> scanDocument();

  Future<CapturedDocument> processScannedDocument(
    DocumentScanDraft draft, {
    String? fileName,
    DocumentCaptureProgressCallback? onProgress,
  });
}
