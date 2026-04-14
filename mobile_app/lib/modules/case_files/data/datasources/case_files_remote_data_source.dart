import '../../../../core/network/api_client.dart';
import '../models/case_file_model.dart';

class CaseFilesRemoteDataSource {
  const CaseFilesRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<CaseFileModel>> getCaseFiles({
    String? term,
    String? status,
  }) async {
    final response = await _apiClient.get(
      '/case-files',
      queryParameters: {
        if (term != null && term.trim().isNotEmpty) 'term': term.trim(),
        if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
      },
    );

    final items = (response as Map<String, dynamic>)['items'] as List<dynamic>;

    return items
        .map((item) => CaseFileModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<CaseFileModel> createCaseFile({
    required String internalCode,
    required String title,
    String? description,
    required String processType,
    required String confidentialityLevel,
  }) async {
    final response = await _apiClient.postJson(
      '/case-files',
      body: {
        'internalCode': internalCode,
        'title': title,
        'description': description,
        'processType': processType,
        'confidentialityLevel': confidentialityLevel,
      },
    );

    return CaseFileModel.fromJson(response as Map<String, dynamic>);
  }

  Future<CaseFileModel> getCaseFileById(String id) async {
    final response = await _apiClient.get('/case-files/$id');

    return CaseFileModel.fromJson(response as Map<String, dynamic>);
  }
}
