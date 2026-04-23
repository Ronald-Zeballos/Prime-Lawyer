import 'dart:io';

import 'package:path_provider/path_provider.dart';

class DocumentCaptureFileStorage {
  Future<String> createDraftPagePath({
    required String sessionId,
    required int pageNumber,
    required String sourcePath,
  }) async {
    final extension = _resolveExtension(sourcePath, fallback: 'jpg');
    final draftDirectory = await _ensureSubdirectory(
      sessionId: sessionId,
      name: 'draft_pages',
    );

    return _joinPath(
      draftDirectory.path,
      'page_${pageNumber.toString().padLeft(3, '0')}.$extension',
    );
  }

  Future<String> createProcessedPagePath({
    required String sessionId,
    required int pageNumber,
  }) async {
    final processedDirectory = await _ensureSubdirectory(
      sessionId: sessionId,
      name: 'processed_pages',
    );

    return _joinPath(
      processedDirectory.path,
      'page_${pageNumber.toString().padLeft(3, '0')}.jpg',
    );
  }

  Future<String> createPdfPath({
    required String sessionId,
    required String fileName,
  }) async {
    final pdfDirectory = await _ensureSubdirectory(
      sessionId: sessionId,
      name: 'pdf',
    );
    final sanitizedName = sanitizePdfFileName(fileName);

    return _joinPath(pdfDirectory.path, sanitizedName);
  }

  Future<String> persistScannerPage({
    required String sessionId,
    required int pageNumber,
    required String sourcePath,
  }) async {
    final targetPath = await createDraftPagePath(
      sessionId: sessionId,
      pageNumber: pageNumber,
      sourcePath: sourcePath,
    );
    final sourceFile = File(sourcePath);

    if (!await sourceFile.exists()) {
      throw StateError('Scanner page is not available: $sourcePath');
    }

    await sourceFile.copy(targetPath);

    return targetPath;
  }

  String buildSuggestedPdfFileName(DateTime createdAt) {
    final year = createdAt.year.toString().padLeft(4, '0');
    final month = createdAt.month.toString().padLeft(2, '0');
    final day = createdAt.day.toString().padLeft(2, '0');
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');

    return 'document_scan_${year}${month}${day}_${hour}${minute}.pdf';
  }

  String sanitizePdfFileName(String value) {
    final normalizedValue = value.trim();
    final withoutExtension = normalizedValue.toLowerCase().endsWith('.pdf')
        ? normalizedValue.substring(0, normalizedValue.length - 4)
        : normalizedValue;
    final sanitizedBaseName = withoutExtension
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .trim();

    if (sanitizedBaseName.isEmpty) {
      return 'document_scan.pdf';
    }

    return '$sanitizedBaseName.pdf';
  }

  String _joinPath(String basePath, String childPath) {
    return '$basePath${Platform.pathSeparator}$childPath';
  }

  Future<Directory> _ensureRootDirectory() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final rootDirectory = Directory(
      _joinPath(documentsDirectory.path, 'document_scans'),
    );

    if (!await rootDirectory.exists()) {
      await rootDirectory.create(recursive: true);
    }

    return rootDirectory;
  }

  Future<Directory> _ensureSessionDirectory(String sessionId) async {
    final rootDirectory = await _ensureRootDirectory();
    final sessionDirectory = Directory(
      _joinPath(rootDirectory.path, sessionId),
    );

    if (!await sessionDirectory.exists()) {
      await sessionDirectory.create(recursive: true);
    }

    return sessionDirectory;
  }

  Future<Directory> _ensureSubdirectory({
    required String sessionId,
    required String name,
  }) async {
    final sessionDirectory = await _ensureSessionDirectory(sessionId);
    final subdirectory = Directory(
      _joinPath(sessionDirectory.path, name),
    );

    if (!await subdirectory.exists()) {
      await subdirectory.create(recursive: true);
    }

    return subdirectory;
  }

  String _resolveExtension(String path, {required String fallback}) {
    final fileName = path.split(RegExp(r'[\\/]')).last;
    final dotIndex = fileName.lastIndexOf('.');

    if (dotIndex == -1 || dotIndex == fileName.length - 1) {
      return fallback;
    }

    return fileName.substring(dotIndex + 1).toLowerCase();
  }
}
