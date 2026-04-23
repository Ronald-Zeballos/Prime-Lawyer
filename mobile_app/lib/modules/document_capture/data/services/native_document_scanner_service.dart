import 'dart:io';

import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';

class NativeDocumentScannerService {
  const NativeDocumentScannerService();

  Future<List<String>> scanPages() async {
    final scanner = DocumentScanner(
      options: DocumentScannerOptions(
        documentFormats: const {DocumentFormat.jpeg},
        pageLimit: 24,
        mode: ScannerMode.full,
        isGalleryImport: true,
      ),
    );

    try {
      final result = await scanner.scanDocument();
      final scannedImages = result.images ?? const <String>[];

      return scannedImages
          .map(_normalizeScannerPath)
          .where((path) => path.trim().isNotEmpty)
          .toList(growable: false);
    } finally {
      await scanner.close();
    }
  }

  String _normalizeScannerPath(String value) {
    final parsedUri = Uri.tryParse(value);

    if (parsedUri != null && parsedUri.scheme == 'file') {
      return parsedUri.toFilePath(windows: Platform.isWindows);
    }

    return value;
  }
}
