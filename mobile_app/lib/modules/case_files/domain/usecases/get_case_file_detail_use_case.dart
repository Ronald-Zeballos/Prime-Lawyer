import '../entities/case_file.dart';
import '../repositories/case_file_repository.dart';

class GetCaseFileDetailUseCase {
  const GetCaseFileDetailUseCase(this._caseFileRepository);

  final CaseFileRepository _caseFileRepository;

  Future<CaseFile> execute(String id) {
    return _caseFileRepository.getCaseFileById(id);
  }
}
