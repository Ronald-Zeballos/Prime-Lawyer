import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/entities/captured_document.dart';
import '../../domain/entities/document_capture_progress.dart';
import '../../domain/entities/document_scan_draft.dart';
import '../../domain/repositories/document_capture_repository.dart';
import '../services/document_capture_file_storage.dart';
import '../services/document_ocr_service.dart';
import '../services/document_page_image_processor.dart';
import '../services/document_pdf_service.dart';
import '../services/native_document_scanner_service.dart';

class MobileDocumentCaptureRepository implements DocumentCaptureRepository {
  MobileDocumentCaptureRepository({
    required NativeDocumentScannerService scannerService,
    required DocumentCaptureFileStorage fileStorage,
    required DocumentPageImageProcessor imageProcessor,
    required DocumentPdfService pdfService,
    required DocumentOcrService ocrService,
  })  : _scannerService = scannerService,
        _fileStorage = fileStorage,
        _imageProcessor = imageProcessor,
        _pdfService = pdfService,
        _ocrService = ocrService;

  final NativeDocumentScannerService _scannerService;
  final DocumentCaptureFileStorage _fileStorage;
  final DocumentPageImageProcessor _imageProcessor;
  final DocumentPdfService _pdfService;
  final DocumentOcrService _ocrService;

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

    final createdAt = DateTime.now();
    final fileName = file.name.trim().isEmpty
        ? _fileStorage.buildSuggestedPdfFileName(createdAt)
        : file.name;

    if (_isPdfFileName(fileName)) {
      return CapturedDocument(
        fileName: fileName,
        mimeType: 'application/pdf',
        bytes: bytes,
        localPath: file.path,
        metadata: CapturedDocumentMetadata(
          documentId: 'picked_${createdAt.microsecondsSinceEpoch}',
          pageCount: 1,
          fileSizeBytes: bytes.length,
          createdAt: createdAt,
        ),
      );
    }

    final pdfBytes = await _convertImageToPdf(bytes);

    return CapturedDocument(
      fileName: _replaceWithPdfExtension(fileName),
      mimeType: 'application/pdf',
      bytes: pdfBytes,
      metadata: CapturedDocumentMetadata(
        documentId: 'picked_${createdAt.microsecondsSinceEpoch}',
        pageCount: 1,
        fileSizeBytes: pdfBytes.length,
        createdAt: createdAt,
      ),
    );
  }

  @override
  Future<CapturedDocument?> captureFromCamera() async {
    final draft = await scanDocument();

    if (draft == null) {
      return null;
    }

    return processScannedDocument(draft);
  }

  @override
  Future<DocumentScanDraft?> scanDocument() async {
    final scannedPaths = await _scannerService.scanPages();

    if (scannedPaths.isEmpty) {
      return null;
    }

    final createdAt = DateTime.now();
    final sessionId = 'scan_${createdAt.microsecondsSinceEpoch}';
    final persistedPages = <DocumentScanDraftPage>[];

    for (var index = 0; index < scannedPaths.length; index++) {
      final persistedPath = await _fileStorage.persistScannerPage(
        sessionId: sessionId,
        pageNumber: index + 1,
        sourcePath: scannedPaths[index],
      );

      persistedPages.add(
        DocumentScanDraftPage(
          id: '${sessionId}_page_${index + 1}',
          sourceImagePath: persistedPath,
        ),
      );
    }

    return DocumentScanDraft(
      id: sessionId,
      createdAt: createdAt,
      suggestedFileName: _fileStorage.buildSuggestedPdfFileName(createdAt),
      pages: persistedPages,
    );
  }

  @override
  Future<CapturedDocument> processScannedDocument(
    DocumentScanDraft draft, {
    String? fileName,
    DocumentCaptureProgressCallback? onProgress,
  }) async {
    if (!draft.hasPages) {
      throw StateError('At least one scanned page is required.');
    }

    final totalSteps = (draft.pages.length * 2) + 1;
    final processedPages = <CapturedDocumentPage>[];

    _emitProgress(
      onProgress,
      DocumentCaptureProgress(
        stage: DocumentCaptureStage.optimizingPages,
        completedSteps: 0,
        totalSteps: totalSteps,
      ),
    );

    for (var index = 0; index < draft.pages.length; index++) {
      final page = draft.pages[index];
      final outputPath = await _fileStorage.createProcessedPagePath(
        sessionId: draft.id,
        pageNumber: index + 1,
      );

      final processedPage = await _imageProcessor.processPage(
        page: page,
        pageNumber: index + 1,
        outputPath: outputPath,
      );

      processedPages.add(processedPage);

      _emitProgress(
        onProgress,
        DocumentCaptureProgress(
          stage: DocumentCaptureStage.optimizingPages,
          completedSteps: index + 1,
          totalSteps: totalSteps,
        ),
      );
    }

    final ocrResult = await _ocrService.recognizePages(
      processedPages,
      onProgress: (current, _) {
        _emitProgress(
          onProgress,
          DocumentCaptureProgress(
            stage: DocumentCaptureStage.recognizingText,
            completedSteps: draft.pages.length + current,
            totalSteps: totalSteps,
          ),
        );
      },
    );
    final resolvedFileName = _fileStorage.sanitizePdfFileName(
      fileName ?? draft.suggestedFileName,
    );

    _emitProgress(
      onProgress,
      DocumentCaptureProgress(
        stage: DocumentCaptureStage.generatingPdf,
        completedSteps: totalSteps - 1,
        totalSteps: totalSteps,
      ),
    );

    final pdfPath = await _fileStorage.createPdfPath(
      sessionId: draft.id,
      fileName: resolvedFileName,
    );
    final generatedPdf = await _pdfService.generatePdf(
      pages: ocrResult.pages,
      outputPath: pdfPath,
    );

    _emitProgress(
      onProgress,
      DocumentCaptureProgress(
        stage: DocumentCaptureStage.completed,
        completedSteps: totalSteps,
        totalSteps: totalSteps,
      ),
    );

    return CapturedDocument(
      fileName: resolvedFileName,
      mimeType: 'application/pdf',
      bytes: generatedPdf.bytes,
      localPath: generatedPdf.path,
      source: DocumentCaptureSource.scanner,
      pages: ocrResult.pages,
      metadata: CapturedDocumentMetadata(
        documentId: draft.id,
        pageCount: ocrResult.pages.length,
        fileSizeBytes: generatedPdf.bytes.length,
        createdAt: draft.createdAt,
      ),
      ocrText: ocrResult.fullText,
      ocrChunks: ocrResult.chunks,
      ocrStatus: ocrResult.status,
    );
  }

  void _emitProgress(
    DocumentCaptureProgressCallback? onProgress,
    DocumentCaptureProgress progress,
  ) {
    onProgress?.call(progress);
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
