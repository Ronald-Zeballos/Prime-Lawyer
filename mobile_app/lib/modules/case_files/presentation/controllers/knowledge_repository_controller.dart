import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/errors/api_exception.dart';
import '../../domain/entities/case_file.dart';
import '../../domain/usecases/get_collaborative_repository_cases_use_case.dart';

class KnowledgeRepositoryController extends ChangeNotifier {
  KnowledgeRepositoryController({
    required GetCollaborativeRepositoryCasesUseCase
        getCollaborativeRepositoryCasesUseCase,
  }) : _getCollaborativeRepositoryCasesUseCase =
            getCollaborativeRepositoryCasesUseCase;

  final GetCollaborativeRepositoryCasesUseCase
      _getCollaborativeRepositoryCasesUseCase;

  final List<CaseFile> _caseFiles = [];
  Timer? _searchDebounce;
  bool _isLoading = false;
  String? _errorMessage;
  String _searchTerm = '';

  List<CaseFile> get caseFiles => List.unmodifiable(_caseFiles);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchTerm => _searchTerm;
  bool get hasCaseFiles => _caseFiles.isNotEmpty;

  Future<void> loadInitialData() {
    return _load();
  }

  Future<void> refresh() {
    return _load();
  }

  void onSearchChanged(String value) {
    _searchTerm = value;
    notifyListeners();

    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 320),
      () {
        _load();
      },
    );
  }

  Future<void> _load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final caseFiles = await _getCollaborativeRepositoryCasesUseCase.execute(
        term: _searchTerm.trim().isEmpty ? null : _searchTerm.trim(),
      );

      _caseFiles
        ..clear()
        ..addAll(caseFiles);
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage =
          'We could not load the collaborative repository right now.';
    }

    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }
}
