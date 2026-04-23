class DocumentAnalysisMatchModel {
  const DocumentAnalysisMatchModel({
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

  factory DocumentAnalysisMatchModel.fromJson(Map<String, dynamic> json) {
    return DocumentAnalysisMatchModel(
      caseFileId: json['caseFileId'] as String? ?? '',
      internalCode: json['internalCode'] as String? ?? '',
      title: json['title'] as String? ?? '',
      processType: json['processType'] as String? ?? '',
      status: json['status'] as String? ?? '',
      visibility: json['visibility'] as String? ?? '',
      knowledgeStatus: json['knowledgeStatus'] as String? ?? '',
      score: (json['score'] as num?)?.round() ?? 0,
      matchedDocumentCount:
          (json['matchedDocumentCount'] as num?)?.round() ?? 0,
      snippet: json['snippet'] as String?,
      matchReasons: ((json['matchReasons'] as List<dynamic>?) ?? const [])
          .whereType<String>()
          .toList(),
    );
  }
}
