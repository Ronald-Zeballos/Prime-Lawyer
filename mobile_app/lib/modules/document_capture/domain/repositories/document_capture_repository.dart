import '../entities/captured_document.dart';

abstract class DocumentCaptureRepository {
  Future<CapturedDocument?> pickDocument();
}
