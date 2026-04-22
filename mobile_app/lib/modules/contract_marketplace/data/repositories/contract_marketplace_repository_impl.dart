import '../../domain/entities/contract_pdf_file.dart';
import '../../domain/entities/contract_template.dart';
import '../../domain/entities/generated_contract.dart';
import '../../domain/repositories/contract_marketplace_repository.dart';
import '../datasources/contract_marketplace_remote_data_source.dart';

class ContractMarketplaceRepositoryImpl
    implements ContractMarketplaceRepository {
  const ContractMarketplaceRepositoryImpl(this._remoteDataSource);

  final ContractMarketplaceRemoteDataSource _remoteDataSource;

  @override
  Future<List<ContractTemplate>> getActiveTemplates() {
    return _remoteDataSource.getActiveTemplates();
  }

  @override
  Future<GeneratedContract> generateContract(GenerateContractInput input) {
    return _remoteDataSource.generateContract(
      templateSlug: input.templateSlug,
      values: input.values,
    );
  }

  @override
  Future<List<GeneratedContract>> getGeneratedContracts() {
    return _remoteDataSource.getGeneratedContracts();
  }

  @override
  Future<ContractPdfFile> getGeneratedContractPdf({
    required String contractInstanceId,
    required String fileName,
  }) {
    return _remoteDataSource.getGeneratedContractPdf(
      contractInstanceId: contractInstanceId,
      fileName: fileName,
    );
  }

  @override
  Future<ContractTemplate> getTemplateBySlug(String slug) {
    return _remoteDataSource.getTemplateBySlug(slug);
  }
}
