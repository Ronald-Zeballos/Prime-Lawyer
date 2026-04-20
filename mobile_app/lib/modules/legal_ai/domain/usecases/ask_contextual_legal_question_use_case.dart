import '../entities/contextual_legal_answer.dart';
import '../repositories/legal_ai_repository.dart';

class AskContextualLegalQuestionInput {
  const AskContextualLegalQuestionInput({
    required this.question,
    this.caseFileId,
    this.documentId,
    this.processType,
    this.limit = 3,
  });

  final String question;
  final String? caseFileId;
  final String? documentId;
  final String? processType;
  final int limit;
}

class AskContextualLegalQuestionUseCase {
  const AskContextualLegalQuestionUseCase(this._legalAiRepository);

  final LegalAiRepository _legalAiRepository;

  Future<ContextualLegalAnswer> execute(
    AskContextualLegalQuestionInput input,
  ) {
    return _legalAiRepository.askContextualQuestion(
      question: input.question,
      caseFileId: input.caseFileId,
      documentId: input.documentId,
      processType: input.processType,
      limit: input.limit,
    );
  }
}
