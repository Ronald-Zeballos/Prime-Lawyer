import 'document_analysis_match_model.dart';

class DocumentAnalysisPreviewModel {
  const DocumentAnalysisPreviewModel({
    required this.mode,
    required this.summary,
    required this.sourceCaseFileId,
    required this.sourceCaseInternalCode,
    required this.sourceCaseTitle,
    required this.sourceProcessType,
    required this.sourceStatus,
    required this.sourceConfidentialityLevel,
    required this.sourceDocumentId,
    required this.sourceDocumentName,
    required this.sourceDocumentType,
    required this.sourceDocumentOcrStatus,
    required this.sourceUploadSource,
    required this.highlights,
    required this.limitations,
    required this.recommendedNextSteps,
    required this.matches,
  });

  final String mode;
  final String summary;
  final String sourceCaseFileId;
  final String sourceCaseInternalCode;
  final String sourceCaseTitle;
  final String sourceProcessType;
  final String sourceStatus;
  final String sourceConfidentialityLevel;
  final String sourceDocumentId;
  final String sourceDocumentName;
  final String sourceDocumentType;
  final String sourceDocumentOcrStatus;
  final String sourceUploadSource;
  final List<String> highlights;
  final List<String> limitations;
  final List<String> recommendedNextSteps;
  final List<DocumentAnalysisMatchModel> matches;

  factory DocumentAnalysisPreviewModel.fromJson(Map<String, dynamic> json) {
    final sourceCaseFile =
        (json['sourceCaseFile'] as Map<String, dynamic>?) ?? const {};
    final sourceDocument =
        (json['sourceDocument'] as Map<String, dynamic>?) ?? const {};

    return DocumentAnalysisPreviewModel(
      mode: json['mode'] as String? ?? 'PREVIEW',
      summary: json['summary'] as String? ?? '',
      sourceCaseFileId: sourceCaseFile['id'] as String? ?? '',
      sourceCaseInternalCode: sourceCaseFile['internalCode'] as String? ?? '',
      sourceCaseTitle: sourceCaseFile['title'] as String? ?? '',
      sourceProcessType: sourceCaseFile['processType'] as String? ?? '',
      sourceStatus: sourceCaseFile['status'] as String? ?? '',
      sourceConfidentialityLevel:
          sourceCaseFile['confidentialityLevel'] as String? ?? '',
      sourceDocumentId: sourceDocument['id'] as String? ?? '',
      sourceDocumentName: sourceDocument['originalName'] as String? ?? '',
      sourceDocumentType: sourceDocument['fileType'] as String? ?? '',
      sourceDocumentOcrStatus: sourceDocument['ocrStatus'] as String? ?? '',
      sourceUploadSource: sourceDocument['uploadSource'] as String? ?? '',
      highlights: ((json['highlights'] as List<dynamic>?) ?? const [])
          .whereType<String>()
          .toList(),
      limitations: ((json['limitations'] as List<dynamic>?) ?? const [])
          .whereType<String>()
          .toList(),
      recommendedNextSteps:
          ((json['recommendedNextSteps'] as List<dynamic>?) ?? const [])
              .whereType<String>()
              .toList(),
      matches: ((json['matches'] as List<dynamic>?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(DocumentAnalysisMatchModel.fromJson)
          .toList(),
    );
  }
}
