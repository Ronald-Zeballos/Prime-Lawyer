import '../entities/case_file.dart';
import '../repositories/case_file_repository.dart';

class GetCaseFilesUseCase {
  const GetCaseFilesUseCase(this._caseFileRepository);

  final CaseFileRepository _caseFileRepository;

  Future<List<CaseFile>> execute({
    String? term,
    String? clientId,
    String? status,
  }) {
    return _caseFileRepository.getCaseFiles(
      term: term,
      clientId: clientId,
      status: status,
    );
  }
}
