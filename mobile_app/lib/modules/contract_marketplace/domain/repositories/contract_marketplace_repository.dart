import '../entities/contract_pdf_file.dart';
import '../entities/contract_template.dart';
import '../entities/generated_contract.dart';

class GenerateContractInput {
  const GenerateContractInput({
    required this.templateSlug,
    required this.values,
  });

  final String templateSlug;
  final Map<String, dynamic> values;
}

abstract class ContractMarketplaceRepository {
  Future<List<ContractTemplate>> getActiveTemplates();
  Future<ContractTemplate> getTemplateBySlug(String slug);
  Future<GeneratedContract> generateContract(GenerateContractInput input);
  Future<List<GeneratedContract>> getGeneratedContracts();
  Future<ContractPdfFile> getGeneratedContractPdf({
    required String contractInstanceId,
    required String fileName,
  });
}
