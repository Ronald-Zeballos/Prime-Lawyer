import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/entities/captured_document.dart';

class GeneratedPdfFile {
  const GeneratedPdfFile({
    required this.path,
    required this.bytes,
  });

  final String path;
  final Uint8List bytes;
}

class DocumentPdfService {
  const DocumentPdfService();

  Future<GeneratedPdfFile> generatePdf({
    required List<CapturedDocumentPage> pages,
    required String outputPath,
  }) async {
    final pdfDocument = pw.Document(compress: true);

    for (final page in pages) {
      final imageBytes = await File(page.processedImagePath).readAsBytes();
      final memoryImage = pw.MemoryImage(imageBytes);
      final pageFormat = page.width > page.height
          ? PdfPageFormat.a4.landscape
          : PdfPageFormat.a4;

      pdfDocument.addPage(
        pw.Page(
          pageFormat: pageFormat,
          margin: const pw.EdgeInsets.all(18),
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
    }

    final pdfBytes = await pdfDocument.save();
    final typedBytes = Uint8List.fromList(pdfBytes);

    await File(outputPath).writeAsBytes(typedBytes, flush: true);

    return GeneratedPdfFile(
      path: outputPath,
      bytes: typedBytes,
    );
  }
}
