import '../entities/case_file.dart';

class CreateCaseFileInput {
  const CreateCaseFileInput({
    required this.internalCode,
    required this.clientId,
    required this.subject,
    required this.processType,
    required this.confidentialityLevel,
  });

  final String internalCode;
  final String clientId;
  final String subject;
  final String processType;
  final String confidentialityLevel;
}

abstract class CaseFileRepository {
  Future<List<CaseFile>> getCaseFiles({
    String? term,
    String? clientId,
    String? status,
  });

  Future<CaseFile> createCaseFile(CreateCaseFileInput input);

  Future<CaseFile> getCaseFileById(String id);
}
