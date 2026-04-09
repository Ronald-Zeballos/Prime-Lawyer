class CaseFileModel {
  const CaseFileModel({
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

  factory CaseFileModel.fromJson(Map<String, dynamic> json) {
    return CaseFileModel(
      id: json['id'] as String,
      internalCode: json['internalCode'] as String,
      clientId: json['clientId'] as String,
      subject: json['subject'] as String,
      processType: json['processType'] as String,
      status: json['status'] as String,
      responsibleUserId: json['responsibleUserId'] as String?,
      openedAt: DateTime.parse(json['openedAt'] as String),
      closedAt: json['closedAt'] == null
          ? null
          : DateTime.parse(json['closedAt'] as String),
      confidentialityLevel: json['confidentialityLevel'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
