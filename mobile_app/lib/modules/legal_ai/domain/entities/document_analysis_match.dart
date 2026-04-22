class DocumentAnalysisMatch {
  const DocumentAnalysisMatch({
    required this.caseFileId,
    required this.internalCode,
    required this.title,
    required this.processType,
    required this.status,
    required this.visibility,
    required this.knowledgeStatus,
    required this.score,
    required this.matchedDocumentCount,
    required this.snippet,
    required this.matchReasons,
  });

  final String caseFileId;
  final String internalCode;
  final String title;
  final String processType;
  final String status;
  final String visibility;
  final String knowledgeStatus;
  final int score;
  final int matchedDocumentCount;
  final String? snippet;
  final List<String> matchReasons;
}
