import '../entities/case_file.dart';

class CreateCaseFileInput {
  const CreateCaseFileInput({
    required this.clientId,
    required this.internalCode,
    required this.title,
    required this.description,
    required this.processType,
    required this.confidentialityLevel,
  });

  final String clientId;
  final String internalCode;
  final String title;
  final String? description;
  final String processType;
  final String confidentialityLevel;
}

abstract class CaseFileRepository {
  Future<List<CaseFile>> getCaseFiles({
    String? term,
    String? status,
  });

  Future<List<CaseFile>> getCollaborativeRepositoryCases({
    String? term,
    String? processType,
  });

  Future<CaseFile> createCaseFile(CreateCaseFileInput input);

  Future<CaseFile> getCaseFileById(String id);

  Future<CaseFile> changeCaseStatus({
    required String caseFileId,
    required String status,
  });

  Future<CaseFile> updateCaseKnowledgePublication({
    required String caseFileId,
    required bool publish,
  });
}
