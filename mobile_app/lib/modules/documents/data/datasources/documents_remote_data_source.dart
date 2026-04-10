import '../../../../core/network/api_client.dart';
import '../../../document_capture/domain/entities/captured_document.dart';
import '../../domain/entities/document_file.dart';
import '../models/document_model.dart';

class DocumentsRemoteDataSource {
  const DocumentsRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<DocumentModel>> getCaseDocuments(String caseFileId) async {
    final response = await _apiClient.get('/case-files/$caseFileId/documents');
    final items = (response as Map<String, dynamic>)['items'] as List<dynamic>;

    return items
        .map((item) => DocumentModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<DocumentFile> getDocumentFile({
    required String documentId,
    required String fileName,
    required String fileType,
  }) async {
    final bytes = await _apiClient.getBytes('/documents/$documentId/file');

    return DocumentFile(
      fileName: fileName,
      fileType: fileType,
      bytes: bytes,
    );
  }

  Future<DocumentModel> registerDocument({
    required String caseFileId,
    required CapturedDocument document,
    String uploadSource = 'mobile_app',
  }) async {
    final response = await _apiClient.sendMultipart(
      '/documents',
      fileFieldName: 'file',
      fileBytes: document.bytes,
      fileName: document.fileName,
      fields: {
        'caseFileId': caseFileId,
        'uploadSource': uploadSource,
      },
    );

    return DocumentModel.fromJson(response as Map<String, dynamic>);
  }
}
