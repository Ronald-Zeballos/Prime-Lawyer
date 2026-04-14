class DocumentAnalysisMatchModel {
  const DocumentAnalysisMatchModel({
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

  factory DocumentAnalysisMatchModel.fromJson(Map<String, dynamic> json) {
    return DocumentAnalysisMatchModel(
      caseFileId: json['caseFileId'] as String? ?? '',
      internalCode: json['internalCode'] as String? ?? '',
      title: json['title'] as String? ?? '',
      processType: json['processType'] as String? ?? '',
      status: json['status'] as String? ?? '',
      score: (json['score'] as num?)?.round() ?? 0,
      matchReasons: ((json['matchReasons'] as List<dynamic>?) ?? const [])
          .whereType<String>()
          .toList(),
    );
  }
}
