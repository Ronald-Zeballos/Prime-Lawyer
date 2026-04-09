class DocumentModel {
  const DocumentModel({
    required this.id,
    required this.caseFileId,
    required this.originalName,
    required this.fileType,
    required this.storagePath,
    required this.hash,
    required this.uploadSource,
    required this.ocrStatus,
    required this.uploadedById,
    required this.uploadedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String caseFileId;
  final String originalName;
  final String fileType;
  final String storagePath;
  final String hash;
  final String uploadSource;
  final String ocrStatus;
  final String uploadedById;
  final DateTime uploadedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] as String,
      caseFileId: json['caseFileId'] as String,
      originalName: json['originalName'] as String,
      fileType: json['fileType'] as String,
      storagePath: json['storagePath'] as String,
      hash: json['hash'] as String,
      uploadSource: json['uploadSource'] as String,
      ocrStatus: json['ocrStatus'] as String,
      uploadedById: json['uploadedById'] as String,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
