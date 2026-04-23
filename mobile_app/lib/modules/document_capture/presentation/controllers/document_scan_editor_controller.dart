import 'package:flutter/foundation.dart';

import '../../domain/entities/captured_document.dart';
import '../../domain/entities/document_capture_progress.dart';
import '../../domain/entities/document_scan_draft.dart';
import '../../domain/usecases/process_scanned_document_use_case.dart';

class DocumentScanEditorController extends ChangeNotifier {
  DocumentScanEditorController({
    required DocumentScanDraft draft,
    required ProcessScannedDocumentUseCase processScannedDocumentUseCase,
  })  : _draft = draft,
        _processScannedDocumentUseCase = processScannedDocumentUseCase;

  final ProcessScannedDocumentUseCase _processScannedDocumentUseCase;
  DocumentScanDraft _draft;
  DocumentCaptureProgress? _progress;
  bool _isProcessing = false;
  String? _errorMessage;

  DocumentScanDraft get draft => _draft;
  DocumentCaptureProgress? get progress => _progress;
  bool get isProcessing => _isProcessing;
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
    _progress = null;
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
      _errorMessage = 'We could not process the scanned document.';
    }

    _isProcessing = false;
    notifyListeners();
    return null;
  }
}
