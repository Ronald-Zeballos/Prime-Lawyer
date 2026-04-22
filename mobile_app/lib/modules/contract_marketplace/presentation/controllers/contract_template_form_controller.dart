import 'package:flutter/foundation.dart';

import '../../../../core/errors/api_exception.dart';
import '../../domain/entities/generated_contract.dart';
import '../../domain/entities/contract_template.dart';
import '../../domain/repositories/contract_marketplace_repository.dart';
import '../../domain/usecases/generate_contract_use_case.dart';
import '../../domain/usecases/get_contract_template_use_case.dart';

class ContractTemplateFormController extends ChangeNotifier {
  ContractTemplateFormController({
    required GetContractTemplateUseCase getContractTemplateUseCase,
    required GenerateContractUseCase generateContractUseCase,
  })  : _getContractTemplateUseCase = getContractTemplateUseCase,
        _generateContractUseCase = generateContractUseCase;

  final GetContractTemplateUseCase _getContractTemplateUseCase;
  final GenerateContractUseCase _generateContractUseCase;

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  ContractTemplate? _template;

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  ContractTemplate? get template => _template;

  Future<void> load(String slug) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _template = await _getContractTemplateUseCase.execute(slug);
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'We could not load this contract template right now.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<GeneratedContract?> generateContract(
    String templateSlug,
    Map<String, dynamic> values,
  ) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final generatedContract = await _generateContractUseCase.execute(
        GenerateContractInput(
          templateSlug: templateSlug,
          values: values,
        ),
      );

      _isSubmitting = false;
      notifyListeners();
      return generatedContract;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'We could not generate the contract right now.';
    }

    _isSubmitting = false;
    notifyListeners();
    return null;
  }
}
