import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/entities/captured_document.dart';
import '../../domain/repositories/document_capture_repository.dart';

class MobileDocumentCaptureRepository implements DocumentCaptureRepository {
  MobileDocumentCaptureRepository({
    ImagePicker? imagePicker,
  }) : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  @override
  Future<CapturedDocument?> pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      withData: true,
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg'],
    );

    final files = result?.files;
    final file = files == null || files.isEmpty ? null : files.first;
    final bytes = file?.bytes;

    if (file == null || bytes == null || bytes.isEmpty) {
      return null;
    }

    if (_isPdfFileName(file.name)) {
      return CapturedDocument(
        fileName: file.name,
        mimeType: 'application/pdf',
        bytes: bytes,
      );
    }

    final pdfBytes = await _convertImageToPdf(bytes);

    return CapturedDocument(
      fileName: _replaceWithPdfExtension(file.name),
      mimeType: 'application/pdf',
      bytes: pdfBytes,
    );
  }

  @override
  Future<CapturedDocument?> captureFromCamera() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (image == null) {
      return null;
    }

    final bytes = await image.readAsBytes();

    if (bytes.isEmpty) {
      return null;
    }

    final fileName = image.name.trim().isEmpty
        ? 'camera_capture_${DateTime.now().millisecondsSinceEpoch}.jpg'
        : image.name;
    final pdfBytes = await _convertImageToPdf(bytes);

    return CapturedDocument(
      fileName: _replaceWithPdfExtension(fileName),
      mimeType: 'application/pdf',
      bytes: pdfBytes,
    );
  }

  bool _isPdfFileName(String fileName) {
    return fileName.trim().toLowerCase().endsWith('.pdf');
  }

  String _replaceWithPdfExtension(String fileName) {
    final trimmedFileName = fileName.trim();
    final dotIndex = trimmedFileName.lastIndexOf('.');

    if (dotIndex <= 0) {
      return '$trimmedFileName.pdf';
    }

    return '${trimmedFileName.substring(0, dotIndex)}.pdf';
  }

  Future<List<int>> _convertImageToPdf(List<int> imageBytes) async {
    final pdfDocument = pw.Document();
    final memoryImage = pw.MemoryImage(Uint8List.fromList(imageBytes));

    pdfDocument.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return pw.Center(
            child: pw.Image(
              memoryImage,
              fit: pw.BoxFit.contain,
            ),
          );
        },
      ),
    );

    return pdfDocument.save();
  }
}
