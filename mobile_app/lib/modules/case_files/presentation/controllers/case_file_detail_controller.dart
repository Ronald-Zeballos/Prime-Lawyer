import 'package:flutter/foundation.dart';

import '../../../../core/errors/api_exception.dart';
import '../../domain/entities/case_file.dart';
import '../../domain/usecases/change_case_file_status_use_case.dart';
import '../../domain/usecases/get_case_file_detail_use_case.dart';
import '../../domain/usecases/update_case_knowledge_publication_use_case.dart';

class CaseFileDetailController extends ChangeNotifier {
  CaseFileDetailController({
    required GetCaseFileDetailUseCase getCaseFileDetailUseCase,
    required ChangeCaseFileStatusUseCase changeCaseFileStatusUseCase,
    required UpdateCaseKnowledgePublicationUseCase
        updateCaseKnowledgePublicationUseCase,
  })  : _getCaseFileDetailUseCase = getCaseFileDetailUseCase,
        _changeCaseFileStatusUseCase = changeCaseFileStatusUseCase,
        _updateCaseKnowledgePublicationUseCase =
            updateCaseKnowledgePublicationUseCase;

  final GetCaseFileDetailUseCase _getCaseFileDetailUseCase;
  final ChangeCaseFileStatusUseCase _changeCaseFileStatusUseCase;
  final UpdateCaseKnowledgePublicationUseCase
      _updateCaseKnowledgePublicationUseCase;

  bool _isLoading = false;
  bool _isUpdatingStatus = false;
  bool _isUpdatingPublication = false;
  String? _errorMessage;
  String? _caseFileId;
  CaseFile? _caseFile;

  bool get isLoading => _isLoading;
  bool get isUpdatingStatus => _isUpdatingStatus;
  bool get isUpdatingPublication => _isUpdatingPublication;
  bool get isBusy =>
      _isLoading || _isUpdatingStatus || _isUpdatingPublication;
  String? get errorMessage => _errorMessage;
  CaseFile? get caseFile => _caseFile;

  Future<void> load(String caseFileId) async {
    _caseFileId = caseFileId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _caseFile = await _getCaseFileDetailUseCase.execute(caseFileId);
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'We could not load this case right now.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> changeStatus(String status) async {
    final caseFileId = _caseFileId;

    if (caseFileId == null || caseFileId.isEmpty) {
      return false;
    }

    _isUpdatingStatus = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _caseFile = await _changeCaseFileStatusUseCase.execute(
        caseFileId: caseFileId,
        status: status,
      );
      await _refreshCaseFileSnapshot(caseFileId);

      _isUpdatingStatus = false;
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'We could not update the case status right now.';
    }

    _isUpdatingStatus = false;
    notifyListeners();
    return false;
  }

  Future<bool> updateKnowledgePublication(bool publish) async {
    final caseFileId = _caseFileId;

    if (caseFileId == null || caseFileId.isEmpty) {
      return false;
    }

    _isUpdatingPublication = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _caseFile = await _updateCaseKnowledgePublicationUseCase.execute(
        caseFileId: caseFileId,
        publish: publish,
      );
      await _refreshCaseFileSnapshot(caseFileId);

      _isUpdatingPublication = false;
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = publish
          ? 'We could not publish this case right now.'
          : 'We could not remove this case from the repository right now.';
    }

    _isUpdatingPublication = false;
    notifyListeners();
    return false;
  }

  Future<void> _refreshCaseFileSnapshot(String caseFileId) async {
    try {
      _caseFile = await _getCaseFileDetailUseCase.execute(caseFileId);
    } catch (_) {
      // Keep the latest successful mutation response if the refresh fails.
    }
  }
}
