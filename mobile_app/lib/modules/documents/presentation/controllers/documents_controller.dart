import 'package:flutter/foundation.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../document_capture/domain/entities/captured_document.dart';
import '../../../document_capture/domain/usecases/pick_document_use_case.dart';
import '../../domain/entities/document.dart';
import '../../domain/repositories/document_repository.dart';
import '../../domain/usecases/get_case_documents_use_case.dart';
import '../../domain/usecases/register_document_use_case.dart';

class DocumentsController extends ChangeNotifier {
  DocumentsController({
    required String caseFileId,
    required GetCaseDocumentsUseCase getCaseDocumentsUseCase,
    required RegisterDocumentUseCase registerDocumentUseCase,
    required PickDocumentUseCase pickDocumentUseCase,
  })  : _caseFileId = caseFileId,
        _getCaseDocumentsUseCase = getCaseDocumentsUseCase,
        _registerDocumentUseCase = registerDocumentUseCase,
        _pickDocumentUseCase = pickDocumentUseCase;

  final String _caseFileId;
  final GetCaseDocumentsUseCase _getCaseDocumentsUseCase;
  final RegisterDocumentUseCase _registerDocumentUseCase;
  final PickDocumentUseCase _pickDocumentUseCase;

  final List<Document> _documents = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  CapturedDocument? _selectedDocument;

  List<Document> get documents => List.unmodifiable(_documents);
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  bool get hasDocuments => _documents.isNotEmpty;
  CapturedDocument? get selectedDocument => _selectedDocument;

  Future<void> loadDocuments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final documents = await _getCaseDocumentsUseCase.execute(_caseFileId);

      _documents
        ..clear()
        ..addAll(documents);
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'We could not load documents right now.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() {
    return loadDocuments();
  }

  Future<void> pickDocument() async {
    _errorMessage = null;
    notifyListeners();

    try {
      final pickedDocument = await _pickDocumentUseCase.execute();

      if (pickedDocument != null) {
        _selectedDocument = pickedDocument;
      }
    } catch (_) {
      _errorMessage = 'We could not open the file picker right now.';
    }

    notifyListeners();
  }

  Future<bool> registerSelectedDocument() async {
    final selectedDocument = _selectedDocument;

    if (selectedDocument == null) {
      _errorMessage = 'Please choose a file first.';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final createdDocument = await _registerDocumentUseCase.execute(
        RegisterDocumentInput(
          caseFileId: _caseFileId,
          document: selectedDocument,
        ),
      );

      _documents.insert(0, createdDocument);
      _selectedDocument = null;
      _isSubmitting = false;
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'We could not register the document right now.';
    }

    _isSubmitting = false;
    notifyListeners();
    return false;
  }

  void clearSelection() {
    _selectedDocument = null;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    notifyListeners();
  }
}
