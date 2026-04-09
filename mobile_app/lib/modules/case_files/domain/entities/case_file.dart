class CaseFile {
  const CaseFile({
    required this.id,
    required this.internalCode,
    required this.clientId,
    required this.subject,
    required this.processType,
    required this.status,
    required this.responsibleUserId,
    required this.openedAt,
    required this.closedAt,
    required this.confidentialityLevel,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String internalCode;
  final String clientId;
  final String subject;
  final String processType;
  final String status;
  final String? responsibleUserId;
  final DateTime openedAt;
  final DateTime? closedAt;
  final String confidentialityLevel;
  final DateTime createdAt;
  final DateTime updatedAt;
}
