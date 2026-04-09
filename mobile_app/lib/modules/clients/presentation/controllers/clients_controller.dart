import 'package:flutter/foundation.dart';

import '../../../../core/errors/api_exception.dart';
import '../../domain/entities/client.dart';
import '../../domain/repositories/client_repository.dart';
import '../../domain/usecases/create_client_use_case.dart';
import '../../domain/usecases/get_clients_use_case.dart';

class ClientsController extends ChangeNotifier {
  ClientsController({
    required GetClientsUseCase getClientsUseCase,
    required CreateClientUseCase createClientUseCase,
  })  : _getClientsUseCase = getClientsUseCase,
        _createClientUseCase = createClientUseCase;

  final GetClientsUseCase _getClientsUseCase;
  final CreateClientUseCase _createClientUseCase;

  final List<Client> _clients = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _searchTerm;

  List<Client> get clients => List.unmodifiable(_clients);
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
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

      _clients
        ..clear()
        ..addAll(clients);
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
}
