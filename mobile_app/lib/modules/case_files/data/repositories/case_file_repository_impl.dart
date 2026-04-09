import '../../domain/entities/case_file.dart';
import '../../domain/repositories/case_file_repository.dart';
import '../datasources/case_files_remote_data_source.dart';
import '../mappers/case_file_mapper.dart';

class CaseFileRepositoryImpl implements CaseFileRepository {
  const CaseFileRepositoryImpl(this._remoteDataSource);

  final CaseFilesRemoteDataSource _remoteDataSource;

  @override
  Future<CaseFile> createCaseFile(CreateCaseFileInput input) async {
    final caseFileModel = await _remoteDataSource.createCaseFile(
      internalCode: input.internalCode,
      clientId: input.clientId,
      subject: input.subject,
      processType: input.processType,
      confidentialityLevel: input.confidentialityLevel,
    );

    return CaseFileMapper.toDomain(caseFileModel);
  }

  @override
  Future<CaseFile> getCaseFileById(String id) async {
    final caseFileModel = await _remoteDataSource.getCaseFileById(id);

    return CaseFileMapper.toDomain(caseFileModel);
  }

  @override
  Future<List<CaseFile>> getCaseFiles({
    String? term,
    String? clientId,
    String? status,
  }) async {
    final caseFileModels = await _remoteDataSource.getCaseFiles(
      term: term,
      clientId: clientId,
      status: status,
    );

    return caseFileModels.map(CaseFileMapper.toDomain).toList();
  }
}
