import '../../domain/entities/document_file.dart';
import '../../domain/entities/document.dart';
import '../../domain/repositories/document_repository.dart';
import '../datasources/documents_remote_data_source.dart';
import '../mappers/document_mapper.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  const DocumentRepositoryImpl(this._remoteDataSource);

  final DocumentsRemoteDataSource _remoteDataSource;

  @override
  Future<List<Document>> getCaseDocuments(String caseFileId) async {
    final documentModels = await _remoteDataSource.getCaseDocuments(caseFileId);

    return documentModels.map(DocumentMapper.toDomain).toList();
  }

  @override
  Future<DocumentFile> getDocumentFile({
    required String documentId,
    required String fileName,
    required String fileType,
  }) {
    return _remoteDataSource.getDocumentFile(
      documentId: documentId,
      fileName: fileName,
      fileType: fileType,
    );
  }

  @override
  Future<Document> registerDocument(RegisterDocumentInput input) async {
    final documentModel = await _remoteDataSource.registerDocument(
      caseFileId: input.caseFileId,
      document: input.document,
      uploadSource: input.uploadSource,
    );

    return DocumentMapper.toDomain(documentModel);
  }
}
