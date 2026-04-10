class DocumentAnalysisMatch {
  const DocumentAnalysisMatch({
    required this.caseFileId,
    required this.internalCode,
    required this.subject,
    required this.processType,
    required this.status,
    required this.score,
    required this.matchReasons,
  });

  final String caseFileId;
  final String internalCode;
  final String subject;
  final String processType;
  final String status;
  final int score;
  final List<String> matchReasons;
}
