import 'package:flutter/foundation.dart';

import '../../../../core/errors/api_exception.dart';
import '../../domain/entities/document_analysis_preview.dart';
import '../../domain/usecases/get_document_analysis_preview_use_case.dart';

class DocumentAnalysisController extends ChangeNotifier {
  DocumentAnalysisController({
    required String documentId,
    required GetDocumentAnalysisPreviewUseCase getDocumentAnalysisPreviewUseCase,
  })  : _documentId = documentId,
        _getDocumentAnalysisPreviewUseCase =
            getDocumentAnalysisPreviewUseCase;

  final String _documentId;
  final GetDocumentAnalysisPreviewUseCase _getDocumentAnalysisPreviewUseCase;

  bool _isLoading = false;
  String? _errorMessage;
  DocumentAnalysisPreview? _analysis;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DocumentAnalysisPreview? get analysis => _analysis;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _analysis = await _getDocumentAnalysisPreviewUseCase.execute(_documentId);
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'We could not analyze this document right now.';
    }

    _isLoading = false;
    notifyListeners();
  }
}
