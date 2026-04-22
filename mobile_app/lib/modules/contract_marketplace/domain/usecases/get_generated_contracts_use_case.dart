import '../entities/generated_contract.dart';
import '../repositories/contract_marketplace_repository.dart';

class GetGeneratedContractsUseCase {
  const GetGeneratedContractsUseCase(this._repository);

  final ContractMarketplaceRepository _repository;

  Future<List<GeneratedContract>> execute() {
    return _repository.getGeneratedContracts();
  }
}
