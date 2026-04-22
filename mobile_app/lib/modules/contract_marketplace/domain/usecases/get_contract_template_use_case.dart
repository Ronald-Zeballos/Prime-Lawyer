import '../entities/contract_template.dart';
import '../repositories/contract_marketplace_repository.dart';

class GetContractTemplateUseCase {
  const GetContractTemplateUseCase(this._repository);

  final ContractMarketplaceRepository _repository;

  Future<ContractTemplate> execute(String slug) {
    return _repository.getTemplateBySlug(slug);
  }
}
