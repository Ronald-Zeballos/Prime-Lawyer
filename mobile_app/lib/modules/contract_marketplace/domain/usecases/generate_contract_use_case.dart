import '../entities/generated_contract.dart';
import '../repositories/contract_marketplace_repository.dart';

class GenerateContractUseCase {
  const GenerateContractUseCase(this._repository);

  final ContractMarketplaceRepository _repository;

  Future<GeneratedContract> execute(GenerateContractInput input) {
    return _repository.generateContract(input);
  }
}
