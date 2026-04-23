class DocumentScanDraftPage {
  const DocumentScanDraftPage({
    required this.id,
    required this.sourceImagePath,
    this.rotationQuarterTurns = 0,
  });

  final String id;
  final String sourceImagePath;
  final int rotationQuarterTurns;

  DocumentScanDraftPage copyWith({
    String? sourceImagePath,
    int? rotationQuarterTurns,
  }) {
    return DocumentScanDraftPage(
      id: id,
      sourceImagePath: sourceImagePath ?? this.sourceImagePath,
      rotationQuarterTurns: rotationQuarterTurns ?? this.rotationQuarterTurns,
    );
  }
}

class DocumentScanDraft {
  const DocumentScanDraft({
    required this.id,
    required this.createdAt,
    required this.suggestedFileName,
    required this.pages,
  });

  final String id;
  final DateTime createdAt;
  final String suggestedFileName;
  final List<DocumentScanDraftPage> pages;

  bool get hasPages => pages.isNotEmpty;

  DocumentScanDraft copyWith({
    String? suggestedFileName,
    List<DocumentScanDraftPage>? pages,
  }) {
    return DocumentScanDraft(
      id: id,
      createdAt: createdAt,
      suggestedFileName: suggestedFileName ?? this.suggestedFileName,
      pages: pages ?? this.pages,
    );
  }
}
