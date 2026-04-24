import 'package:flutter/foundation.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../case_files/domain/entities/case_file.dart';
import '../../../case_files/domain/usecases/get_case_files_use_case.dart';
import '../../domain/entities/client.dart';
import '../../domain/repositories/client_repository.dart';
import '../../domain/usecases/create_client_use_case.dart';
import '../../domain/usecases/delete_client_use_case.dart';
import '../../domain/usecases/get_clients_use_case.dart';
import '../../domain/usecases/update_client_use_case.dart';

class ClientsController extends ChangeNotifier {
  ClientsController({
    required GetClientsUseCase getClientsUseCase,
    required CreateClientUseCase createClientUseCase,
    required UpdateClientUseCase updateClientUseCase,
    required DeleteClientUseCase deleteClientUseCase,
    required GetCaseFilesUseCase getCaseFilesUseCase,
  })  : _getClientsUseCase = getClientsUseCase,
        _createClientUseCase = createClientUseCase,
        _updateClientUseCase = updateClientUseCase,
        _deleteClientUseCase = deleteClientUseCase,
        _getCaseFilesUseCase = getCaseFilesUseCase;

  final GetClientsUseCase _getClientsUseCase;
  final CreateClientUseCase _createClientUseCase;
  final UpdateClientUseCase _updateClientUseCase;
  final DeleteClientUseCase _deleteClientUseCase;
  final GetCaseFilesUseCase _getCaseFilesUseCase;

  final List<Client> _clients = [];
  final List<CaseFile> _caseFiles = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _deletingClientId;
  String? _errorMessage;
  String? _searchTerm;

  List<Client> get clients => List.unmodifiable(_clients);
  List<CaseFile> get caseFiles => List.unmodifiable(_caseFiles);
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get deletingClientId => _deletingClientId;
  String? get errorMessage => _errorMessage;
  bool get hasClients => _clients.isNotEmpty;
  String? get searchTerm => _searchTerm;

  Future<void> loadClients({
    String? term,
    bool silent = false,
  }) async {
    _searchTerm = term;

    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final clients = await _getClientsUseCase.execute(term: term);
      List<CaseFile> caseFiles = const <CaseFile>[];

      try {
        caseFiles = await _getCaseFilesUseCase.execute();
      } on ApiException catch (error) {
        _errorMessage = error.message;
      } catch (_) {
        _errorMessage = 'We could not load linked case files right now.';
      }

      _clients
        ..clear()
        ..addAll(clients);
      _caseFiles
        ..clear()
        ..addAll(caseFiles);
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'We could not load clients right now.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createClient(CreateClientInput input) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final client = await _createClientUseCase.execute(input);

      _clients.insert(0, client);
      await _refreshAfterMutation();
      _isSubmitting = false;
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'We could not create the client right now.';
    }

    _isSubmitting = false;
    notifyListeners();
    return false;
  }

  Future<bool> updateClient(UpdateClientInput input) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedClient = await _updateClientUseCase.execute(input);
      final index =
          _clients.indexWhere((client) => client.id == input.clientId);

      if (index == -1) {
        _clients.insert(0, updatedClient);
      } else {
        _clients[index] = updatedClient;
      }

      await _refreshAfterMutation();
      _isSubmitting = false;
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'We could not update the client right now.';
    }

    _isSubmitting = false;
    notifyListeners();
    return false;
  }

  Future<bool> deleteClient(String clientId) async {
    _deletingClientId = clientId;
    _errorMessage = null;
    notifyListeners();

    try {
      await _deleteClientUseCase.execute(clientId);
      _clients.removeWhere((client) => client.id == clientId);
      await _refreshAfterMutation();
      _deletingClientId = null;
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'We could not delete the client right now.';
    }

    _deletingClientId = null;
    notifyListeners();
    return false;
  }

  Future<void> refresh() {
    return loadClients(
      term: _searchTerm,
      silent: false,
    );
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    notifyListeners();
  }

  Client? getClientById(String clientId) {
    try {
      return _clients.firstWhere((client) => client.id == clientId);
    } catch (_) {
      return null;
    }
  }

  List<CaseFile> linkedCaseFilesForClient(String clientId) {
    return _caseFiles
        .where((caseFile) => caseFile.clientId == clientId)
        .toList(growable: false);
  }

  int linkedCaseFilesCount(String clientId) {
    return linkedCaseFilesForClient(clientId).length;
  }

  int activeLinkedCaseFilesCount(String clientId) {
    return linkedCaseFilesForClient(clientId).where((caseFile) {
      return caseFile.status == 'OPEN' || caseFile.status == 'IN_PROGRESS';
    }).length;
  }

  bool canDeleteClient(String clientId) {
    return linkedCaseFilesCount(clientId) == 0;
  }

  bool isDeletingClient(String clientId) {
    return _deletingClientId == clientId;
  }

  Future<void> _refreshAfterMutation() async {
    try {
      final clients = await _getClientsUseCase.execute(term: _searchTerm);
      final caseFiles = await _getCaseFilesUseCase.execute();

      _clients
        ..clear()
        ..addAll(clients);
      _caseFiles
        ..clear()
        ..addAll(caseFiles);
    } on ApiException {
      // Keep the latest local mutation if the follow-up refresh fails.
    } catch (_) {
      // Keep the latest local mutation if the follow-up refresh fails.
    }
  }
}
