import 'package:flutter/foundation.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../documents/domain/entities/document.dart';
import '../../../documents/domain/usecases/process_document_ocr_use_case.dart';
import '../../domain/entities/document_analysis_preview.dart';
import '../../domain/usecases/get_document_analysis_preview_use_case.dart';

class DocumentAnalysisController extends ChangeNotifier {
  DocumentAnalysisController({
    required Document document,
    required GetDocumentAnalysisPreviewUseCase
        getDocumentAnalysisPreviewUseCase,
    required ProcessDocumentOcrUseCase processDocumentOcrUseCase,
  })  : _document = document,
        _getDocumentAnalysisPreviewUseCase = getDocumentAnalysisPreviewUseCase,
        _processDocumentOcrUseCase = processDocumentOcrUseCase;

  Document _document;
  final GetDocumentAnalysisPreviewUseCase _getDocumentAnalysisPreviewUseCase;
  final ProcessDocumentOcrUseCase _processDocumentOcrUseCase;

  bool _isLoading = false;
  String? _errorMessage;
  DocumentAnalysisPreview? _analysis;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DocumentAnalysisPreview? get analysis => _analysis;
  Document get document => _document;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _prepareDocumentIfNeeded();
      _analysis =
          await _getDocumentAnalysisPreviewUseCase.execute(_document.id);
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'We could not analyze this document right now.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() {
    return load();
  }

  Future<void> _prepareDocumentIfNeeded() async {
    if (!_shouldProcessOcr(_document)) {
      return;
    }

    try {
      _document = await _processDocumentOcrUseCase.execute(_document.id);
    } on ApiException {
      // Ignore this here so analysis can still try metadata-based retrieval.
    }
  }

  bool _shouldProcessOcr(Document document) {
    final normalizedOcrStatus = document.ocrStatus.trim().toUpperCase();

    if (normalizedOcrStatus == 'PROCESSING') {
      return false;
    }

    return document.isScannedDocument ||
        !document.hasOcrText ||
        normalizedOcrStatus == 'PENDING' ||
        normalizedOcrStatus == 'FAILED' ||
        normalizedOcrStatus == 'ERROR';
  }
}
