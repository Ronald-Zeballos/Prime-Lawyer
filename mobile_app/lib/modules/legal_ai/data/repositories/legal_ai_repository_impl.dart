import '../../domain/entities/contextual_legal_answer.dart';
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

  @override
  Future<ContextualLegalAnswer> askContextualQuestion({
    required String question,
    String? caseFileId,
    String? documentId,
    String? processType,
    int limit = 3,
  }) async {
    final answerModel = await _remoteDataSource.askContextualQuestion(
      question: question,
      caseFileId: caseFileId,
      documentId: documentId,
      processType: processType,
      limit: limit,
    );

    return LegalAiMapper.contextualAnswerToDomain(answerModel);
  }
}
