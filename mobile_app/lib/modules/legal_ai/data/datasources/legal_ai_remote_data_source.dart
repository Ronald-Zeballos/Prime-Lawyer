import '../../../../core/network/api_client.dart';
import '../models/contextual_legal_answer_model.dart';
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

  Future<ContextualLegalAnswerModel> askContextualQuestion({
    required String question,
    String? caseFileId,
    String? documentId,
    String? processType,
    int limit = 3,
  }) async {
    final payload = <String, dynamic>{
      'question': question,
      'caseFileId': caseFileId,
      'documentId': documentId,
      'processType': processType,
      'limit': limit,
    }..removeWhere(
        (key, value) =>
            value == null ||
            (value is String && value.trim().isEmpty),
      );

    final response = await _apiClient.postJson(
      '/legal-ai/consultations',
      body: payload,
    );

    return ContextualLegalAnswerModel.fromJson(
      response as Map<String, dynamic>,
    );
  }
}
