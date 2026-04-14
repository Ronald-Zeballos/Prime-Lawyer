import 'document_analysis_match.dart';

class DocumentAnalysisPreview {
  const DocumentAnalysisPreview({
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
  final List<DocumentAnalysisMatch> matches;

  bool get hasMatches => matches.isNotEmpty;
}
