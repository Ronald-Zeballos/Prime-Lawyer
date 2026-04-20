class ContextualLegalAnswer {
  const ContextualLegalAnswer({
    required this.queryId,
    required this.mode,
    required this.question,
    required this.sourceCaseFile,
    required this.sourceDocument,
    required this.usedContextCases,
    required this.usedContextDocuments,
    required this.createdAt,
    required this.language,
    required this.groundingStatus,
    required this.answer,
    required this.disclaimer,
    required this.limitations,
    required this.recommendedNextSteps,
    required this.followUpQuestions,
  });

  final String queryId;
  final String mode;
  final String question;
  final LegalAiSourceCaseFile? sourceCaseFile;
  final LegalAiSourceDocument? sourceDocument;
  final List<LegalAiContextCase> usedContextCases;
  final List<LegalAiContextDocument> usedContextDocuments;
  final DateTime createdAt;
  final String language;
  final String groundingStatus;
  final String answer;
  final String disclaimer;
  final List<String> limitations;
  final List<String> recommendedNextSteps;
  final List<String> followUpQuestions;

  bool get isGrounded => groundingStatus == 'GROUNDED';
  bool get isPartial => groundingStatus == 'PARTIAL';
  bool get isInsufficientContext => groundingStatus == 'INSUFFICIENT_CONTEXT';
  bool get hasSourceCase => sourceCaseFile != null;
  bool get hasSourceDocument => sourceDocument != null;
  bool get hasUsedContextCases => usedContextCases.isNotEmpty;
  bool get hasUsedContextDocuments => usedContextDocuments.isNotEmpty;
}

class LegalAiSourceCaseFile {
  const LegalAiSourceCaseFile({
    required this.id,
    required this.internalCode,
    required this.title,
    required this.descriptionSnippet,
    required this.processType,
    required this.status,
    required this.visibility,
    required this.knowledgeStatus,
  });

  final String id;
  final String internalCode;
  final String title;
  final String? descriptionSnippet;
  final String processType;
  final String status;
  final String visibility;
  final String knowledgeStatus;

  String get displayLabel => '$internalCode · $title';
}

class LegalAiSourceDocument {
  const LegalAiSourceDocument({
    required this.id,
    required this.caseFileId,
    required this.originalName,
    required this.fileType,
    required this.ocrStatus,
    required this.uploadSource,
    required this.snippet,
  });

  final String id;
  final String caseFileId;
  final String originalName;
  final String fileType;
  final String ocrStatus;
  final String uploadSource;
  final String? snippet;
}

class LegalAiContextCase {
  const LegalAiContextCase({
    required this.rank,
    required this.relation,
    required this.caseFileId,
    required this.internalCode,
    required this.title,
    required this.processType,
    required this.status,
    required this.visibility,
    required this.knowledgeStatus,
    required this.score,
    required this.snippet,
    required this.matchReasons,
  });

  final int rank;
  final String relation;
  final String caseFileId;
  final String internalCode;
  final String title;
  final String processType;
  final String status;
  final String visibility;
  final String knowledgeStatus;
  final int score;
  final String? snippet;
  final List<String> matchReasons;

  String get displayLabel => '$internalCode · $title';
}

class LegalAiContextDocument {
  const LegalAiContextDocument({
    required this.rank,
    required this.relation,
    required this.documentId,
    required this.caseFileId,
    required this.caseInternalCode,
    required this.caseTitle,
    required this.processType,
    required this.status,
    required this.originalName,
    required this.fileType,
    required this.ocrStatus,
    required this.score,
    required this.snippet,
    required this.matchReasons,
  });

  final int rank;
  final String relation;
  final String documentId;
  final String caseFileId;
  final String caseInternalCode;
  final String caseTitle;
  final String processType;
  final String status;
  final String originalName;
  final String fileType;
  final String ocrStatus;
  final int score;
  final String? snippet;
  final List<String> matchReasons;

  String get caseDisplayLabel => '$caseInternalCode · $caseTitle';
}
