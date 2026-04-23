import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import '../../domain/entities/captured_document.dart';
import '../../domain/entities/document_scan_draft.dart';

class DocumentPageImageProcessor {
  const DocumentPageImageProcessor();

  Future<CapturedDocumentPage> processPage({
    required DocumentScanDraftPage page,
    required int pageNumber,
    required String outputPath,
  }) async {
    final result = await compute<Map<String, Object?>, Map<String, Object?>>(
      _optimizePageImage,
      <String, Object?>{
        'pageId': page.id,
        'sourcePath': page.sourceImagePath,
        'outputPath': outputPath,
        'rotationQuarterTurns': page.rotationQuarterTurns,
        'maxLongSide': 2200,
        'quality': 88,
      },
    );

    return CapturedDocumentPage(
      id: result['pageId'] as String,
      pageNumber: pageNumber,
      originalImagePath: page.sourceImagePath,
      processedImagePath: outputPath,
      rotationQuarterTurns: page.rotationQuarterTurns,
      width: result['width'] as int,
      height: result['height'] as int,
      fileSizeBytes: result['sizeBytes'] as int,
    );
  }
}

Map<String, Object?> _optimizePageImage(Map<String, Object?> payload) {
  final sourcePath = payload['sourcePath'] as String;
  final outputPath = payload['outputPath'] as String;
  final rotationQuarterTurns = payload['rotationQuarterTurns'] as int? ?? 0;
  final maxLongSide = payload['maxLongSide'] as int? ?? 2200;
  final quality = payload['quality'] as int? ?? 88;
  final sourceFile = File(sourcePath);
  final sourceBytes = sourceFile.readAsBytesSync();
  final decodedImage = img.decodeImage(sourceBytes);

  if (decodedImage == null) {
    File(outputPath).writeAsBytesSync(sourceBytes, flush: true);

    return <String, Object?>{
      'pageId': payload['pageId'],
      'width': 0,
      'height': 0,
      'sizeBytes': sourceBytes.length,
    };
  }

  img.Image processedImage = img.bakeOrientation(decodedImage);

  if (rotationQuarterTurns != 0) {
    processedImage = img.copyRotate(
      processedImage,
      angle: rotationQuarterTurns * 90,
    );
  }

  final longSide = math.max(processedImage.width, processedImage.height);

  if (longSide > maxLongSide) {
    final resizeFactor = maxLongSide / longSide;
    final resizedWidth = (processedImage.width * resizeFactor).round();
    final resizedHeight = (processedImage.height * resizeFactor).round();

    processedImage = img.copyResize(
      processedImage,
      width: resizedWidth,
      height: resizedHeight,
      interpolation: img.Interpolation.average,
    );
  }

  final jpgBytes = img.encodeJpg(processedImage, quality: quality);

  File(outputPath).writeAsBytesSync(jpgBytes, flush: true);

  return <String, Object?>{
    'pageId': payload['pageId'],
    'width': processedImage.width,
    'height': processedImage.height,
    'sizeBytes': jpgBytes.length,
  };
}
