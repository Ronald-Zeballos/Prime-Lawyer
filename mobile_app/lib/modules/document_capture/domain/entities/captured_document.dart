enum DocumentCaptureSource {
  filePicker,
  scanner,
}

enum DocumentOcrStatus {
  pending,
  processing,
  done,
  error,
}

class CapturedDocumentMetadata {
  const CapturedDocumentMetadata({
    required this.documentId,
    required this.pageCount,
    required this.fileSizeBytes,
    required this.createdAt,
  });

  final String documentId;
  final int pageCount;
  final int fileSizeBytes;
  final DateTime createdAt;
}

class CapturedDocumentPage {
  const CapturedDocumentPage({
    required this.id,
    required this.pageNumber,
    required this.originalImagePath,
    required this.processedImagePath,
    required this.rotationQuarterTurns,
    required this.width,
    required this.height,
    required this.fileSizeBytes,
    this.ocrText,
  });

  final String id;
  final int pageNumber;
  final String originalImagePath;
  final String processedImagePath;
  final int rotationQuarterTurns;
  final int width;
  final int height;
  final int fileSizeBytes;
  final String? ocrText;

  CapturedDocumentPage copyWith({
    int? pageNumber,
    String? processedImagePath,
    int? rotationQuarterTurns,
    int? width,
    int? height,
    int? fileSizeBytes,
    String? ocrText,
  }) {
    return CapturedDocumentPage(
      id: id,
      pageNumber: pageNumber ?? this.pageNumber,
      originalImagePath: originalImagePath,
      processedImagePath: processedImagePath ?? this.processedImagePath,
      rotationQuarterTurns: rotationQuarterTurns ?? this.rotationQuarterTurns,
      width: width ?? this.width,
      height: height ?? this.height,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      ocrText: ocrText ?? this.ocrText,
    );
  }
}

class SearchableDocumentPayload {
  const SearchableDocumentPayload({
    required this.documentId,
    required this.pdfUrl,
    required this.pages,
    required this.ocrText,
    required this.ocrChunks,
    required this.createdAt,
  });

  final String documentId;
  final String pdfUrl;
  final int pages;
  final String ocrText;
  final List<String> ocrChunks;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'documentId': documentId,
      'pdfUrl': pdfUrl,
      'pages': pages,
      'ocrText': ocrText,
      'ocrChunks': ocrChunks,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class CapturedDocument {
  const CapturedDocument({
    required this.fileName,
    required this.mimeType,
    required this.bytes,
    this.localPath,
    this.source = DocumentCaptureSource.filePicker,
    this.pages = const [],
    this.metadata,
    this.ocrText,
    this.ocrChunks = const [],
    this.ocrStatus = DocumentOcrStatus.pending,
  });

  final String fileName;
  final String mimeType;
  final List<int> bytes;
  final String? localPath;
  final DocumentCaptureSource source;
  final List<CapturedDocumentPage> pages;
  final CapturedDocumentMetadata? metadata;
  final String? ocrText;
  final List<String> ocrChunks;
  final DocumentOcrStatus ocrStatus;

  bool get isPdf => mimeType == 'application/pdf';

  bool get isScannerDocument => source == DocumentCaptureSource.scanner;

  int get pageCount =>
      metadata?.pageCount ?? (pages.isEmpty ? 1 : pages.length);

  int get sizeBytes => metadata?.fileSizeBytes ?? bytes.length;

  DateTime? get createdAt => metadata?.createdAt;

  bool get hasOcrText => ocrText != null && ocrText!.trim().isNotEmpty;

  String get ocrStatusValue {
    switch (ocrStatus) {
      case DocumentOcrStatus.pending:
        return 'PENDING';
      case DocumentOcrStatus.processing:
        return 'PROCESSING';
      case DocumentOcrStatus.done:
        return 'DONE';
      case DocumentOcrStatus.error:
        return 'ERROR';
    }
  }

  String get documentSourceValue {
    switch (source) {
      case DocumentCaptureSource.filePicker:
        return 'FILE_UPLOAD';
      case DocumentCaptureSource.scanner:
        return 'CAMERA';
    }
  }

  List<String> get pageOcrTexts {
    return pages
        .map((page) => page.ocrText?.trim() ?? '')
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  String get ocrPreview {
    final normalizedText =
        (ocrText ?? '').replaceAll(RegExp(r'\s+'), ' ').trim();

    if (normalizedText.length <= 220) {
      return normalizedText;
    }

    return '${normalizedText.substring(0, 220).trim()}...';
  }

  SearchableDocumentPayload? get searchablePayload {
    final resolvedMetadata = metadata;
    final resolvedLocalPath = localPath;

    if (resolvedMetadata == null || resolvedLocalPath == null) {
      return null;
    }

    return SearchableDocumentPayload(
      documentId: resolvedMetadata.documentId,
      pdfUrl: resolvedLocalPath,
      pages: resolvedMetadata.pageCount,
      ocrText: ocrText ?? '',
      ocrChunks: ocrChunks,
      createdAt: resolvedMetadata.createdAt,
    );
  }
}
