class DocumentAnalysisDocumentMatch {
  const DocumentAnalysisDocumentMatch({
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
}
