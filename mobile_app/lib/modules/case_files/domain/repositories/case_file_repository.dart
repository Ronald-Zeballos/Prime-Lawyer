import '../entities/case_file.dart';

class CreateCaseFileInput {
  const CreateCaseFileInput({
    required this.internalCode,
    required this.title,
    required this.description,
    required this.processType,
    required this.confidentialityLevel,
  });

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

  Future<CaseFile> createCaseFile(CreateCaseFileInput input);

  Future<CaseFile> getCaseFileById(String id);
}
