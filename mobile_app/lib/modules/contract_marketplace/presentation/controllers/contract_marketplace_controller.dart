import 'package:flutter/foundation.dart';

import '../../../../core/errors/api_exception.dart';
import '../../domain/entities/contract_template.dart';
import '../../domain/entities/generated_contract.dart';
import '../../domain/usecases/get_active_contract_templates_use_case.dart';
import '../../domain/usecases/get_generated_contracts_use_case.dart';

class ContractMarketplaceController extends ChangeNotifier {
  ContractMarketplaceController({
    required GetActiveContractTemplatesUseCase
        getActiveContractTemplatesUseCase,
    required GetGeneratedContractsUseCase getGeneratedContractsUseCase,
  })  : _getActiveContractTemplatesUseCase = getActiveContractTemplatesUseCase,
        _getGeneratedContractsUseCase = getGeneratedContractsUseCase;

  final GetActiveContractTemplatesUseCase _getActiveContractTemplatesUseCase;
  final GetGeneratedContractsUseCase _getGeneratedContractsUseCase;

  bool _isLoading = false;
  String? _errorMessage;
  List<ContractTemplate> _templates = const [];
  List<GeneratedContract> _generatedContracts = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ContractTemplate> get templates => _templates;
  List<GeneratedContract> get generatedContracts => _generatedContracts;
  bool get hasTemplates => _templates.isNotEmpty;
  bool get hasGeneratedContracts => _generatedContracts.isNotEmpty;

  Future<void> loadInitialData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final templates = await _getActiveContractTemplatesUseCase.execute();
      final generatedContracts = await _getGeneratedContractsUseCase.execute();

      _templates = templates;
      _generatedContracts = generatedContracts;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'We could not load the contract marketplace right now.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() {
    return loadInitialData();
  }
}
