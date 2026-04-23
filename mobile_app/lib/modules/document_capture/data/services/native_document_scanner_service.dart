import 'dart:io';

import 'package:flutter/services.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:image_picker/image_picker.dart';

class NativeDocumentScannerService {
  NativeDocumentScannerService({
    ImagePicker? imagePicker,
  }) : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  Future<List<String>> scanPages() async {
    final scanner = DocumentScanner(
      options: DocumentScannerOptions(
        documentFormats: const {DocumentFormat.jpeg},
        pageLimit: 24,
        mode: ScannerMode.full,
        isGalleryImport: true,
      ),
    );

    try {
      final result = await scanner.scanDocument();
      final scannedImages = result.images ?? const <String>[];

      return scannedImages
          .map(_normalizeScannerPath)
          .where((path) => path.trim().isNotEmpty)
          .toList(growable: false);
    } on PlatformException catch (error) {
      final fallbackCapture = await _captureSinglePageFromCamera();

      if (fallbackCapture.isNotEmpty) {
        return fallbackCapture;
      }

      if (_isPermissionDenied(error)) {
        throw StateError('camera_permission_denied');
      }

      throw StateError('scanner_unavailable');
    } finally {
      await scanner.close();
    }
  }

  Future<List<String>> _captureSinglePageFromCamera() async {
    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 92,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (file == null || file.path.trim().isEmpty) {
        return const <String>[];
      }

      return <String>[file.path];
    } on PlatformException catch (error) {
      if (_isPermissionDenied(error)) {
        throw StateError('camera_permission_denied');
      }

      return const <String>[];
    }
  }

  bool _isPermissionDenied(PlatformException error) {
    final normalizedCode = error.code.toLowerCase();
    final normalizedMessage = (error.message ?? '').toLowerCase();

    return normalizedCode.contains('permission') ||
        normalizedCode.contains('denied') ||
        normalizedMessage.contains('permission') ||
        normalizedMessage.contains('denied');
  }

  String _normalizeScannerPath(String value) {
    final parsedUri = Uri.tryParse(value);

    if (parsedUri != null && parsedUri.scheme == 'file') {
      return parsedUri.toFilePath(windows: Platform.isWindows);
    }

    return value;
  }
}
