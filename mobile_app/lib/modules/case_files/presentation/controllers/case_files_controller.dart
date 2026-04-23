import 'package:flutter/foundation.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../clients/domain/entities/client.dart';
import '../../../clients/domain/usecases/get_clients_use_case.dart';
import '../../domain/entities/case_file.dart';
import '../../domain/repositories/case_file_repository.dart';
import '../../domain/usecases/create_case_file_use_case.dart';
import '../../domain/usecases/get_case_files_use_case.dart';

class CaseFilesController extends ChangeNotifier {
  CaseFilesController({
    required GetCaseFilesUseCase getCaseFilesUseCase,
    required CreateCaseFileUseCase createCaseFileUseCase,
    required GetClientsUseCase getClientsUseCase,
  })  : _getCaseFilesUseCase = getCaseFilesUseCase,
        _createCaseFileUseCase = createCaseFileUseCase,
        _getClientsUseCase = getClientsUseCase;

  final GetCaseFilesUseCase _getCaseFilesUseCase;
  final CreateCaseFileUseCase _createCaseFileUseCase;
  final GetClientsUseCase _getClientsUseCase;

  final List<CaseFile> _caseFiles = [];
  final List<Client> _clients = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  List<CaseFile> get caseFiles => List.unmodifiable(_caseFiles);
  List<Client> get clients => List.unmodifiable(_clients);
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  bool get hasCaseFiles => _caseFiles.isNotEmpty;
  bool get hasClients => _clients.isNotEmpty;

  Future<void> loadInitialData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait<dynamic>([
        _getCaseFilesUseCase.execute(),
        _getClientsUseCase.execute(),
      ]);
      final caseFiles = results[0] as List<CaseFile>;
      final clients = results[1] as List<Client>;

      _caseFiles
        ..clear()
        ..addAll(caseFiles);
      _clients
        ..clear()
        ..addAll(clients);
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'We could not load cases right now.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createCaseFile(CreateCaseFileInput input) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final caseFile = await _createCaseFileUseCase.execute(input);

      _caseFiles.insert(0, caseFile);
      _isSubmitting = false;
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'We could not create the case right now.';
    }

    _isSubmitting = false;
    notifyListeners();
    return false;
  }

  Future<void> refresh() {
    return loadInitialData();
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    notifyListeners();
  }
}
