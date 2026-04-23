class Document {
  const Document({
    required this.id,
    required this.caseFileId,
    required this.originalName,
    required this.fileType,
    required this.storagePath,
    required this.hash,
    required this.uploadSource,
    required this.ocrStatus,
    required this.ocrText,
    required this.ocrProcessedAt,
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
  final String? ocrText;
  final DateTime? ocrProcessedAt;
  final String uploadedById;
  final DateTime uploadedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isPdf =>
      fileType.toLowerCase() == 'application/pdf' ||
      originalName.toLowerCase().endsWith('.pdf');

  bool get hasOcrText => ocrText != null && ocrText!.trim().isNotEmpty;

  String get ocrPreview {
    final normalizedText =
        (ocrText ?? '').replaceAll(RegExp(r'\s+'), ' ').trim();

    if (normalizedText.length <= 220) {
      return normalizedText;
    }

    return '${normalizedText.substring(0, 220).trim()}...';
  }
}
