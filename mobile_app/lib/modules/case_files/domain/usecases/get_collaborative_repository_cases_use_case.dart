import '../entities/case_file.dart';
import '../repositories/case_file_repository.dart';

class GetCollaborativeRepositoryCasesUseCase {
  const GetCollaborativeRepositoryCasesUseCase(this._caseFileRepository);

  final CaseFileRepository _caseFileRepository;

  Future<List<CaseFile>> execute({
    String? term,
    String? processType,
  }) {
    return _caseFileRepository.getCollaborativeRepositoryCases(
      term: term,
      processType: processType,
    );
  }
}
