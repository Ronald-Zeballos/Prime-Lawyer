import '../../../../core/network/api_client.dart';
import '../../domain/entities/contract_pdf_file.dart';
import '../models/contract_template_model.dart';
import '../models/generated_contract_model.dart';

class ContractMarketplaceRemoteDataSource {
  const ContractMarketplaceRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ContractTemplateModel>> getActiveTemplates() async {
    final response = await _apiClient.get('/contract-marketplace/templates');
    final items = (response as Map<String, dynamic>)['items'] as List<dynamic>;

    return items
        .whereType<Map<String, dynamic>>()
        .map(ContractTemplateModel.fromJson)
        .toList();
  }

  Future<ContractTemplateModel> getTemplateBySlug(String slug) async {
    final response = await _apiClient.get('/contract-marketplace/templates/$slug');

    return ContractTemplateModel.fromJson(response as Map<String, dynamic>);
  }

  Future<GeneratedContractModel> generateContract({
    required String templateSlug,
    required Map<String, dynamic> values,
  }) async {
    final response = await _apiClient.postJson(
      '/contract-marketplace/templates/$templateSlug/generate',
      body: {
        'values': values,
      },
    );

    return GeneratedContractModel.fromJson(response as Map<String, dynamic>);
  }

  Future<List<GeneratedContractModel>> getGeneratedContracts() async {
    final response = await _apiClient.get('/contract-marketplace/instances');
    final items = (response as Map<String, dynamic>)['items'] as List<dynamic>;

    return items
        .whereType<Map<String, dynamic>>()
        .map(GeneratedContractModel.fromJson)
        .toList();
  }

  Future<ContractPdfFile> getGeneratedContractPdf({
    required String contractInstanceId,
    required String fileName,
  }) async {
    final bytes = await _apiClient.getBytes(
      '/contract-marketplace/instances/$contractInstanceId/file',
    );

    return ContractPdfFile(
      fileName: fileName,
      fileType: 'application/pdf',
      bytes: bytes,
    );
  }
}
