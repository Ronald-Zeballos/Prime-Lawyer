import '../entities/case_file.dart';
import '../repositories/case_file_repository.dart';

class UpdateCaseKnowledgePublicationUseCase {
  const UpdateCaseKnowledgePublicationUseCase(this._caseFileRepository);

  final CaseFileRepository _caseFileRepository;

  Future<CaseFile> execute({
    required String caseFileId,
    required bool publish,
  }) {
    return _caseFileRepository.updateCaseKnowledgePublication(
      caseFileId: caseFileId,
      publish: publish,
    );
  }
}
