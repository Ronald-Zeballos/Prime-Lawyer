import '../entities/captured_document.dart';
import '../repositories/document_capture_repository.dart';

class CaptureDocumentFromCameraUseCase {
  const CaptureDocumentFromCameraUseCase(this._documentCaptureRepository);

  final DocumentCaptureRepository _documentCaptureRepository;

  Future<CapturedDocument?> execute() {
    return _documentCaptureRepository.captureFromCamera();
  }
}
