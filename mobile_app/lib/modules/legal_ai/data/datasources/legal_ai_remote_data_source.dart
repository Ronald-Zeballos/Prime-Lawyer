import '../../../../core/network/api_client.dart';
import '../models/document_analysis_preview_model.dart';

class LegalAiRemoteDataSource {
  const LegalAiRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<DocumentAnalysisPreviewModel> getDocumentAnalysisPreview(
    String documentId,
  ) async {
    final response = await _apiClient.get(
      '/legal-ai/documents/$documentId/analysis-preview',
    );

    return DocumentAnalysisPreviewModel.fromJson(
      response as Map<String, dynamic>,
    );
  }
}
