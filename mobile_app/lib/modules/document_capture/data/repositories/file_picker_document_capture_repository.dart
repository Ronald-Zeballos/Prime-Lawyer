import 'package:file_picker/file_picker.dart';

import '../../domain/entities/captured_document.dart';
import '../../domain/entities/document_scan_draft.dart';
import '../../domain/repositories/document_capture_repository.dart';

class FilePickerDocumentCaptureRepository implements DocumentCaptureRepository {
  const FilePickerDocumentCaptureRepository();

  @override
  Future<CapturedDocument?> pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      withData: true,
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg', 'doc', 'docx'],
    );

    final files = result?.files;
    final file = files == null || files.isEmpty ? null : files.first;
    final bytes = file?.bytes;

    if (file == null || bytes == null || bytes.isEmpty) {
      return null;
    }

    return CapturedDocument(
      fileName: file.name,
      mimeType: 'application/pdf',
      bytes: bytes,
    );
  }

  @override
  Future<CapturedDocument?> captureFromCamera() async {
    return null;
  }

  @override
  Future<DocumentScanDraft?> scanDocument() async {
    return null;
  }

  @override
  Future<CapturedDocument> processScannedDocument(
    DocumentScanDraft draft, {
    String? fileName,
    DocumentCaptureProgressCallback? onProgress,
  }) {
    throw UnimplementedError(
      'Processing scanned documents is not available in the file picker repository.',
    );
  }
}
