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
      clientId: input.clientId,
      internalCode: input.internalCode,
      title: input.title,
      description: input.description,
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
  Future<CaseFile> changeCaseStatus({
    required String caseFileId,
    required String status,
  }) async {
    final caseFileModel = await _remoteDataSource.changeCaseStatus(
      caseFileId: caseFileId,
      status: status,
    );

    return CaseFileMapper.toDomain(caseFileModel);
  }

  @override
  Future<List<CaseFile>> getCaseFiles({
    String? term,
    String? status,
  }) async {
    final caseFileModels = await _remoteDataSource.getCaseFiles(
      term: term,
      status: status,
    );

    return caseFileModels.map(CaseFileMapper.toDomain).toList();
  }

  @override
  Future<List<CaseFile>> getCollaborativeRepositoryCases({
    String? term,
    String? processType,
  }) async {
    final caseFileModels =
        await _remoteDataSource.getCollaborativeRepositoryCases(
      term: term,
      processType: processType,
    );

    return caseFileModels.map(CaseFileMapper.toDomain).toList();
  }

  @override
  Future<CaseFile> updateCaseKnowledgePublication({
    required String caseFileId,
    required bool publish,
  }) async {
    final caseFileModel =
        await _remoteDataSource.updateCaseKnowledgePublication(
      caseFileId: caseFileId,
      publish: publish,
    );

    return CaseFileMapper.toDomain(caseFileModel);
  }
}
