import 'package:flutter/foundation.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../clients/domain/entities/client.dart';
import '../../../clients/domain/usecases/get_clients_use_case.dart';
import '../../domain/entities/case_file.dart';
import '../../domain/usecases/get_case_file_detail_use_case.dart';

class CaseFileDetailController extends ChangeNotifier {
  CaseFileDetailController({
    required GetCaseFileDetailUseCase getCaseFileDetailUseCase,
    required GetClientsUseCase getClientsUseCase,
  })  : _getCaseFileDetailUseCase = getCaseFileDetailUseCase,
        _getClientsUseCase = getClientsUseCase;

  final GetCaseFileDetailUseCase _getCaseFileDetailUseCase;
  final GetClientsUseCase _getClientsUseCase;

  bool _isLoading = false;
  String? _errorMessage;
  CaseFile? _caseFile;
  final List<Client> _clients = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  CaseFile? get caseFile => _caseFile;

  Future<void> load(String caseFileId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait<dynamic>([
        _getCaseFileDetailUseCase.execute(caseFileId),
        _getClientsUseCase.execute(),
      ]);

      _caseFile = results[0] as CaseFile;
      final clients = results[1] as List<Client>;

      _clients
        ..clear()
        ..addAll(clients);
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'We could not load this case file right now.';
    }

    _isLoading = false;
    notifyListeners();
  }

  String? get clientLabel {
    final caseFile = _caseFile;

    if (caseFile == null) {
      return null;
    }

    for (final client in _clients) {
      if (client.id == caseFile.clientId) {
        return client.fullName;
      }
    }

    return caseFile.clientId;
  }
}
