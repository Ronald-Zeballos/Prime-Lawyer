class ContextualLegalAnswerModel {
  const ContextualLegalAnswerModel({
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
  final LegalAiSourceCaseFileModel? sourceCaseFile;
  final LegalAiSourceDocumentModel? sourceDocument;
  final List<LegalAiContextCaseModel> usedContextCases;
  final List<LegalAiContextDocumentModel> usedContextDocuments;
  final DateTime createdAt;
  final String language;
  final String groundingStatus;
  final String answer;
  final String disclaimer;
  final List<String> limitations;
  final List<String> recommendedNextSteps;
  final List<String> followUpQuestions;

  factory ContextualLegalAnswerModel.fromJson(Map<String, dynamic> json) {
    final sourceCaseFile = json['sourceCaseFile'];
    final sourceDocument = json['sourceDocument'];

    return ContextualLegalAnswerModel(
      queryId: json['queryId'] as String? ?? '',
      mode: json['mode'] as String? ?? 'CONTEXTUAL_HEURISTIC',
      question: json['question'] as String? ?? '',
      sourceCaseFile: sourceCaseFile is Map<String, dynamic>
          ? LegalAiSourceCaseFileModel.fromJson(sourceCaseFile)
          : null,
      sourceDocument: sourceDocument is Map<String, dynamic>
          ? LegalAiSourceDocumentModel.fromJson(sourceDocument)
          : null,
      usedContextCases:
          ((json['usedContextCases'] as List<dynamic>?) ?? const [])
              .whereType<Map<String, dynamic>>()
              .map(LegalAiContextCaseModel.fromJson)
              .toList(),
      usedContextDocuments:
          ((json['usedContextDocuments'] as List<dynamic>?) ?? const [])
              .whereType<Map<String, dynamic>>()
              .map(LegalAiContextDocumentModel.fromJson)
              .toList(),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      language: json['language'] as String? ?? 'es',
      groundingStatus:
          json['groundingStatus'] as String? ?? 'INSUFFICIENT_CONTEXT',
      answer: json['answer'] as String? ?? '',
      disclaimer: json['disclaimer'] as String? ?? '',
      limitations: ((json['limitations'] as List<dynamic>?) ?? const [])
          .whereType<String>()
          .toList(),
      recommendedNextSteps:
          ((json['recommendedNextSteps'] as List<dynamic>?) ?? const [])
              .whereType<String>()
              .toList(),
      followUpQuestions:
          ((json['followUpQuestions'] as List<dynamic>?) ?? const [])
              .whereType<String>()
              .toList(),
    );
  }
}

class LegalAiSourceCaseFileModel {
  const LegalAiSourceCaseFileModel({
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

  factory LegalAiSourceCaseFileModel.fromJson(Map<String, dynamic> json) {
    return LegalAiSourceCaseFileModel(
      id: json['id'] as String? ?? '',
      internalCode: json['internalCode'] as String? ?? '',
      title: json['title'] as String? ?? '',
      descriptionSnippet: json['descriptionSnippet'] as String?,
      processType: json['processType'] as String? ?? '',
      status: json['status'] as String? ?? '',
      visibility: json['visibility'] as String? ?? '',
      knowledgeStatus: json['knowledgeStatus'] as String? ?? '',
    );
  }
}

class LegalAiSourceDocumentModel {
  const LegalAiSourceDocumentModel({
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

  factory LegalAiSourceDocumentModel.fromJson(Map<String, dynamic> json) {
    return LegalAiSourceDocumentModel(
      id: json['id'] as String? ?? '',
      caseFileId: json['caseFileId'] as String? ?? '',
      originalName: json['originalName'] as String? ?? '',
      fileType: json['fileType'] as String? ?? '',
      ocrStatus: json['ocrStatus'] as String? ?? '',
      uploadSource: json['uploadSource'] as String? ?? '',
      snippet: json['snippet'] as String?,
    );
  }
}

class LegalAiContextCaseModel {
  const LegalAiContextCaseModel({
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

  factory LegalAiContextCaseModel.fromJson(Map<String, dynamic> json) {
    return LegalAiContextCaseModel(
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      relation: json['relation'] as String? ?? 'SIMILAR_CASE',
      caseFileId: json['caseFileId'] as String? ?? '',
      internalCode: json['internalCode'] as String? ?? '',
      title: json['title'] as String? ?? '',
      processType: json['processType'] as String? ?? '',
      status: json['status'] as String? ?? '',
      visibility: json['visibility'] as String? ?? '',
      knowledgeStatus: json['knowledgeStatus'] as String? ?? '',
      score: (json['score'] as num?)?.toInt() ?? 0,
      snippet: json['snippet'] as String?,
      matchReasons: ((json['matchReasons'] as List<dynamic>?) ?? const [])
          .whereType<String>()
          .toList(),
    );
  }
}

class LegalAiContextDocumentModel {
  const LegalAiContextDocumentModel({
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

  factory LegalAiContextDocumentModel.fromJson(Map<String, dynamic> json) {
    return LegalAiContextDocumentModel(
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      relation: json['relation'] as String? ?? 'SIMILAR_DOCUMENT',
      documentId: json['documentId'] as String? ?? '',
      caseFileId: json['caseFileId'] as String? ?? '',
      caseInternalCode: json['caseInternalCode'] as String? ?? '',
      caseTitle: json['caseTitle'] as String? ?? '',
      processType: json['processType'] as String? ?? '',
      status: json['status'] as String? ?? '',
      originalName: json['originalName'] as String? ?? '',
      fileType: json['fileType'] as String? ?? '',
      ocrStatus: json['ocrStatus'] as String? ?? '',
      score: (json['score'] as num?)?.toInt() ?? 0,
      snippet: json['snippet'] as String?,
      matchReasons: ((json['matchReasons'] as List<dynamic>?) ?? const [])
          .whereType<String>()
          .toList(),
    );
  }
}
