import '../entities/case_file.dart';
import '../repositories/case_file_repository.dart';

class CreateCaseFileUseCase {
  const CreateCaseFileUseCase(this._caseFileRepository);

  final CaseFileRepository _caseFileRepository;

  Future<CaseFile> execute(CreateCaseFileInput input) {
    return _caseFileRepository.createCaseFile(input);
  }
}
