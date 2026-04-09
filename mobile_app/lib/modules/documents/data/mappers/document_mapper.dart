import '../../domain/entities/document.dart';
import '../models/document_model.dart';

class DocumentMapper {
  const DocumentMapper._();

  static Document toDomain(DocumentModel model) {
    return Document(
      id: model.id,
      caseFileId: model.caseFileId,
      originalName: model.originalName,
      fileType: model.fileType,
      storagePath: model.storagePath,
      hash: model.hash,
      uploadSource: model.uploadSource,
      ocrStatus: model.ocrStatus,
      uploadedById: model.uploadedById,
      uploadedAt: model.uploadedAt,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }
}
