import '../../domain/entities/document_analysis_preview.dart';
import '../../domain/repositories/legal_ai_repository.dart';
import '../datasources/legal_ai_remote_data_source.dart';
import '../mappers/legal_ai_mapper.dart';

class LegalAiRepositoryImpl implements LegalAiRepository {
  const LegalAiRepositoryImpl(this._remoteDataSource);

  final LegalAiRemoteDataSource _remoteDataSource;

  @override
  Future<DocumentAnalysisPreview> getDocumentAnalysisPreview(
    String documentId,
  ) async {
    final previewModel =
        await _remoteDataSource.getDocumentAnalysisPreview(documentId);

    return LegalAiMapper.toDomain(previewModel);
  }
}
