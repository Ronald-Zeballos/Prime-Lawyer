class DocumentAnalysisDocumentMatchModel {
  const DocumentAnalysisDocumentMatchModel({
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

  factory DocumentAnalysisDocumentMatchModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return DocumentAnalysisDocumentMatchModel(
      documentId: json['documentId'] as String? ?? '',
      caseFileId: json['caseFileId'] as String? ?? '',
      caseInternalCode: json['caseInternalCode'] as String? ?? '',
      caseTitle: json['caseTitle'] as String? ?? '',
      processType: json['processType'] as String? ?? '',
      status: json['status'] as String? ?? '',
      originalName: json['originalName'] as String? ?? '',
      fileType: json['fileType'] as String? ?? '',
      ocrStatus: json['ocrStatus'] as String? ?? '',
      score: (json['score'] as num?)?.round() ?? 0,
      snippet: json['snippet'] as String?,
      matchReasons: ((json['matchReasons'] as List<dynamic>?) ?? const [])
          .whereType<String>()
          .toList(),
    );
  }
}
