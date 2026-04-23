import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../domain/entities/captured_document.dart';

class DocumentOcrResult {
  const DocumentOcrResult({
    required this.pages,
    required this.fullText,
    required this.chunks,
    required this.status,
  });

  final List<CapturedDocumentPage> pages;
  final String fullText;
  final List<String> chunks;
  final DocumentOcrStatus status;
}

class DocumentOcrService {
  const DocumentOcrService();

  Future<DocumentOcrResult> recognizePages(
    List<CapturedDocumentPage> pages, {
    void Function(int current, int total)? onProgress,
  }) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final updatedPages = <CapturedDocumentPage>[];
    final pageTexts = <String>[];
    var hasFatalError = false;

    try {
      for (var index = 0; index < pages.length; index++) {
        final page = pages[index];

        try {
          final inputImage = InputImage.fromFilePath(page.processedImagePath);
          final recognizedText = await recognizer.processImage(inputImage);
          final normalizedText = _normalizeText(recognizedText.text);

          updatedPages.add(
            page.copyWith(
              ocrText: normalizedText,
            ),
          );

          if (normalizedText.isNotEmpty) {
            pageTexts.add(normalizedText);
          }
        } catch (_) {
          hasFatalError = true;
          updatedPages.add(
            page.copyWith(
              ocrText: '',
            ),
          );
        }

        onProgress?.call(index + 1, pages.length);
      }
    } finally {
      await recognizer.close();
    }

    final fullText = pageTexts.join('\n\n').trim();

    return DocumentOcrResult(
      pages: updatedPages,
      fullText: fullText,
      chunks: _chunkText(fullText),
      status: hasFatalError && fullText.isEmpty
          ? DocumentOcrStatus.error
          : DocumentOcrStatus.done,
    );
  }

  String _normalizeText(String value) {
    return value
        .replaceAll('\r\n', '\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  List<String> _chunkText(String value) {
    if (value.trim().isEmpty) {
      return const <String>[];
    }

    final paragraphs = value
        .split(RegExp(r'\n{2,}'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty);
    final chunks = <String>[];
    final buffer = StringBuffer();

    for (final paragraph in paragraphs) {
      if (buffer.isEmpty) {
        buffer.write(paragraph);
        continue;
      }

      final candidate = '${buffer.toString()}\n\n$paragraph';

      if (candidate.length <= 900) {
        buffer
          ..clear()
          ..write(candidate);
        continue;
      }

      chunks.add(buffer.toString());
      buffer
        ..clear()
        ..write(paragraph);
    }

    if (buffer.isNotEmpty) {
      chunks.add(buffer.toString());
    }

    return chunks;
  }
}
