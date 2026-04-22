import '../entities/case_file.dart';
import '../repositories/case_file_repository.dart';

class ChangeCaseFileStatusUseCase {
  const ChangeCaseFileStatusUseCase(this._caseFileRepository);

  final CaseFileRepository _caseFileRepository;

  Future<CaseFile> execute({
    required String caseFileId,
    required String status,
  }) {
    return _caseFileRepository.changeCaseStatus(
      caseFileId: caseFileId,
      status: status,
    );
  }
}
