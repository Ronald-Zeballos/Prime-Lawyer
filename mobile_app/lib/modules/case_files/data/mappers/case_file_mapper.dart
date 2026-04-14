import '../../domain/entities/case_file.dart';
import '../models/case_file_model.dart';

class CaseFileMapper {
  const CaseFileMapper._();

  static CaseFile toDomain(CaseFileModel model) {
    return CaseFile(
      id: model.id,
      internalCode: model.internalCode,
      ownerUserId: model.ownerUserId,
      title: model.title,
      description: model.description,
      processType: model.processType,
      status: model.status,
      responsibleUserId: model.responsibleUserId,
      openedAt: model.openedAt,
      closedAt: model.closedAt,
      visibility: model.visibility,
      knowledgeStatus: model.knowledgeStatus,
      confidentialityLevel: model.confidentialityLevel,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }
}
