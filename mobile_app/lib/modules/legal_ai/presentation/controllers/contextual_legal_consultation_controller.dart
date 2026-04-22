import 'package:flutter/foundation.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../case_files/domain/entities/case_file.dart';
import '../../../case_files/domain/usecases/get_case_files_use_case.dart';
import '../../../documents/domain/entities/document.dart';
import '../../../documents/domain/usecases/get_case_documents_use_case.dart';
import '../../domain/entities/contextual_legal_answer.dart';
import '../../domain/usecases/ask_contextual_legal_question_use_case.dart';

class ContextualLegalConsultationController extends ChangeNotifier {
  ContextualLegalConsultationController({
    required GetCaseFilesUseCase getCaseFilesUseCase,
    required GetCaseDocumentsUseCase getCaseDocumentsUseCase,
    required AskContextualLegalQuestionUseCase
        askContextualLegalQuestionUseCase,
    String? initialCaseFileId,
    String? initialDocumentId,
  })  : _getCaseFilesUseCase = getCaseFilesUseCase,
        _getCaseDocumentsUseCase = getCaseDocumentsUseCase,
        _askContextualLegalQuestionUseCase =
            askContextualLegalQuestionUseCase,
        _initialCaseFileId = initialCaseFileId,
        _initialDocumentId = initialDocumentId;

  final GetCaseFilesUseCase _getCaseFilesUseCase;
  final GetCaseDocumentsUseCase _getCaseDocumentsUseCase;
  final AskContextualLegalQuestionUseCase _askContextualLegalQuestionUseCase;
  final String? _initialCaseFileId;
  final String? _initialDocumentId;

  final List<CaseFile> _caseFiles = [];
  final List<Document> _documents = [];
  final List<ContextualLegalAnswer> _consultationHistory = [];

  bool _hasBootstrapped = false;
  bool _isBootstrapping = false;
  bool _isLoadingDocuments = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _selectedCaseFileId;
  String? _selectedDocumentId;
  ContextualLegalAnswer? _answer;

  List<CaseFile> get caseFiles => List.unmodifiable(_caseFiles);
  List<Document> get documents => List.unmodifiable(_documents);
  List<ContextualLegalAnswer> get consultationHistory =>
      List.unmodifiable(_consultationHistory);
  bool get isBootstrapping => _isBootstrapping;
  bool get isLoadingDocuments => _isLoadingDocuments;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get selectedCaseFileId => _selectedCaseFileId;
  String? get selectedDocumentId => _selectedDocumentId;
  ContextualLegalAnswer? get answer => _answer;
  bool get hasDocuments => _documents.isNotEmpty;
  bool get hasAnswer => _answer != null;
  bool get hasConsultationHistory => _consultationHistory.isNotEmpty;

  CaseFile? get selectedCaseFile {
    final selectedCaseFileId = _selectedCaseFileId;

    if (selectedCaseFileId == null) {
      return null;
    }

    for (final caseFile in _caseFiles) {
      if (caseFile.id == selectedCaseFileId) {
        return caseFile;
      }
    }

    return null;
  }

  Document? get selectedDocument {
    final selectedDocumentId = _selectedDocumentId;

    if (selectedDocumentId == null) {
      return null;
    }

    for (final document in _documents) {
      if (document.id == selectedDocumentId) {
        return document;
      }
    }

    return null;
  }

  Future<void> bootstrap() async {
    if (_hasBootstrapped) {
      return;
    }

    _hasBootstrapped = true;
    _isBootstrapping = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final caseFiles = await _getCaseFilesUseCase.execute();

      _caseFiles
        ..clear()
        ..addAll(caseFiles);

      final hasInitialCase = _initialCaseFileId != null &&
          _caseFiles.any((caseFile) => caseFile.id == _initialCaseFileId);

      _selectedCaseFileId = hasInitialCase ? _initialCaseFileId : null;

      if (_selectedCaseFileId != null) {
        await _loadDocumentsForCase(
          _selectedCaseFileId!,
          preferredDocumentId: _initialDocumentId,
          notify: false,
        );
      } else {
        _documents.clear();
        _selectedDocumentId = null;
      }
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'We could not prepare legal AI right now.';
    }

    _isBootstrapping = false;
    notifyListeners();
  }

  Future<void> selectCaseFile(String? caseFileId) async {
    if (_selectedCaseFileId == caseFileId) {
      return;
    }

    _selectedCaseFileId = caseFileId;
    _selectedDocumentId = null;
    _documents.clear();
    _answer = null;
    _errorMessage = null;
    notifyListeners();

    if (caseFileId == null || caseFileId.isEmpty) {
      return;
    }

    await _loadDocumentsForCase(caseFileId);
  }

  void selectDocument(String? documentId) {
    if (_selectedDocumentId == documentId) {
      return;
    }

    _selectedDocumentId = documentId;
    _answer = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> askQuestion(String question) async {
    final normalizedQuestion = question.trim();

    if (normalizedQuestion.isEmpty) {
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _answer = await _askContextualLegalQuestionUseCase.execute(
        AskContextualLegalQuestionInput(
          question: normalizedQuestion,
          caseFileId: _selectedCaseFileId,
          documentId: _selectedDocumentId,
          processType: selectedCaseFile?.processType,
          limit: 3,
        ),
      );
      _pushAnswerToHistory(_answer!);
      _isSubmitting = false;
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'We could not complete the legal consultation.';
    }

    _isSubmitting = false;
    notifyListeners();
    return false;
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    notifyListeners();
  }

  void showHistoryAnswer(String queryId) {
    for (final item in _consultationHistory) {
      if (item.queryId == queryId) {
        _answer = item;
        _errorMessage = null;
        notifyListeners();
        return;
      }
    }
  }

  void clearCurrentAnswer() {
    if (_answer == null && _errorMessage == null) {
      return;
    }

    _answer = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _loadDocumentsForCase(
    String caseFileId, {
    String? preferredDocumentId,
    bool notify = true,
  }) async {
    _isLoadingDocuments = true;
    _errorMessage = null;

    if (notify) {
      notifyListeners();
    }

    try {
      final documents = await _getCaseDocumentsUseCase.execute(caseFileId);

      _documents
        ..clear()
        ..addAll(documents);

      final hasPreferredDocument = preferredDocumentId != null &&
          _documents.any((document) => document.id == preferredDocumentId);

      _selectedDocumentId = hasPreferredDocument ? preferredDocumentId : null;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      _documents.clear();
      _selectedDocumentId = null;
    } catch (_) {
      _errorMessage = 'We could not load documents for this case file.';
      _documents.clear();
      _selectedDocumentId = null;
    }

    _isLoadingDocuments = false;

    if (notify) {
      notifyListeners();
    }
  }

  void _pushAnswerToHistory(ContextualLegalAnswer answer) {
    _consultationHistory.removeWhere((item) => item.queryId == answer.queryId);
    _consultationHistory.insert(0, answer);

    if (_consultationHistory.length > 6) {
      _consultationHistory.removeRange(6, _consultationHistory.length);
    }
  }
}
