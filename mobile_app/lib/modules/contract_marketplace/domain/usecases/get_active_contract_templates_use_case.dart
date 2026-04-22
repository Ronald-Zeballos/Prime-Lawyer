import '../entities/contract_template.dart';
import '../repositories/contract_marketplace_repository.dart';

class GetActiveContractTemplatesUseCase {
  const GetActiveContractTemplatesUseCase(this._repository);

  final ContractMarketplaceRepository _repository;

  Future<List<ContractTemplate>> execute() {
    return _repository.getActiveTemplates();
  }
}
