import 'package:flutter/foundation.dart';

import '../../../../core/errors/api_exception.dart';
import '../../domain/entities/case_file.dart';
import '../../domain/usecases/get_case_file_detail_use_case.dart';

class CaseFileDetailController extends ChangeNotifier {
  CaseFileDetailController({
    required GetCaseFileDetailUseCase getCaseFileDetailUseCase,
  }) : _getCaseFileDetailUseCase = getCaseFileDetailUseCase;

  final GetCaseFileDetailUseCase _getCaseFileDetailUseCase;

  bool _isLoading = false;
  String? _errorMessage;
  CaseFile? _caseFile;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  CaseFile? get caseFile => _caseFile;

  Future<void> load(String caseFileId) async {
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
}
