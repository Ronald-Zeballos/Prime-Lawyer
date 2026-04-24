import 'package:flutter/foundation.dart';

import '../../domain/entities/captured_document.dart';
import '../../domain/entities/document_capture_progress.dart';
import '../../domain/entities/document_scan_draft.dart';
import '../../domain/usecases/process_scanned_document_use_case.dart';
import '../../domain/usecases/start_document_scan_use_case.dart';

class DocumentScanEditorController extends ChangeNotifier {
  DocumentScanEditorController({
    required DocumentScanDraft draft,
    required ProcessScannedDocumentUseCase processScannedDocumentUseCase,
    required StartDocumentScanUseCase startDocumentScanUseCase,
  })  : _draft = draft,
        _processScannedDocumentUseCase = processScannedDocumentUseCase,
        _startDocumentScanUseCase = startDocumentScanUseCase;

  final ProcessScannedDocumentUseCase _processScannedDocumentUseCase;
  final StartDocumentScanUseCase _startDocumentScanUseCase;
  DocumentScanDraft _draft;
  DocumentCaptureProgress? _progress;
  bool _isProcessing = false;
  bool _isAddingPages = false;
  String? _errorMessage;

  DocumentScanDraft get draft => _draft;
  DocumentCaptureProgress? get progress => _progress;
  bool get isProcessing => _isProcessing;
  bool get isAddingPages => _isAddingPages;
  String? get errorMessage => _errorMessage;
  bool get hasPages => _draft.pages.isNotEmpty;

  void reorderPages(int oldIndex, int newIndex) {
    if (_isProcessing) {
      return;
    }

    final pages = List<DocumentScanDraftPage>.from(_draft.pages);

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final page = pages.removeAt(oldIndex);
    pages.insert(newIndex, page);
    _draft = _draft.copyWith(pages: pages);
    notifyListeners();
  }

  void rotatePage(String pageId) {
    if (_isProcessing) {
      return;
    }

    final updatedPages = _draft.pages
        .map((page) => page.id == pageId
            ? page.copyWith(
                rotationQuarterTurns: (page.rotationQuarterTurns + 1) % 4,
              )
            : page)
        .toList(growable: false);

    _draft = _draft.copyWith(pages: updatedPages);
    notifyListeners();
  }

  void removePage(String pageId) {
    if (_isProcessing) {
      return;
    }

    final updatedPages =
        _draft.pages.where((page) => page.id != pageId).toList(growable: false);

    _draft = _draft.copyWith(pages: updatedPages);
    notifyListeners();
  }

  Future<void> addMorePages() async {
    if (_isProcessing || _isAddingPages) {
      return;
    }

    _isAddingPages = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final additionalDraft = await _startDocumentScanUseCase.execute();

      if (additionalDraft != null && additionalDraft.pages.isNotEmpty) {
        _draft = _draft.copyWith(
          pages: [
            ..._draft.pages,
            ...additionalDraft.pages,
          ],
        );
      }
    } catch (error) {
      _errorMessage =
          error is StateError && error.message == 'camera_permission_denied'
              ? 'Camera permission was denied. Please enable it and try again.'
              : 'We could not scan additional pages right now.';
    }

    _isAddingPages = false;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    notifyListeners();
  }

  Future<CapturedDocument?> finalizeDocument() async {
    if (_draft.pages.isEmpty) {
      _errorMessage = 'At least one page is required.';
      notifyListeners();
      return null;
    }

    _isProcessing = true;
    _errorMessage = null;
    _progress = const DocumentCaptureProgress(
      stage: DocumentCaptureStage.optimizingPages,
      completedSteps: 0,
      totalSteps: 1,
    );
    notifyListeners();

    try {
      final document = await _processScannedDocumentUseCase.execute(
        _draft,
        onProgress: (progress) {
          _progress = progress;
          notifyListeners();
        },
      );

      _isProcessing = false;
      notifyListeners();
      return document;
    } catch (_) {
      _errorMessage =
          'We could not process the scanned document into a PDF right now.';
    }

    _isProcessing = false;
    notifyListeners();
    return null;
  }
}
