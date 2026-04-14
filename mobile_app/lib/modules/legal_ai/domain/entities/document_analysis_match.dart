class DocumentAnalysisMatch {
  const DocumentAnalysisMatch({
    required this.caseFileId,
    required this.internalCode,
    required this.title,
    required this.processType,
    required this.status,
    required this.score,
    required this.matchReasons,
  });

  final String caseFileId;
  final String internalCode;
  final String title;
  final String processType;
  final String status;
  final int score;
  final List<String> matchReasons;
}
