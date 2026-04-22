class CaseFile {
  const CaseFile({
    required this.id,
    required this.internalCode,
    required this.ownerUserId,
    required this.title,
    required this.description,
    required this.processType,
    required this.status,
    required this.responsibleUserId,
    required this.openedAt,
    required this.closedAt,
    required this.visibility,
    required this.knowledgeStatus,
    required this.publishedAt,
    required this.confidentialityLevel,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String internalCode;
  final String ownerUserId;
  final String title;
  final String? description;
  final String processType;
  final String status;
  final String? responsibleUserId;
  final DateTime openedAt;
  final DateTime? closedAt;
  final String visibility;
  final String knowledgeStatus;
  final DateTime? publishedAt;
  final String confidentialityLevel;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get displayLabel => '$internalCode · $title';
}
