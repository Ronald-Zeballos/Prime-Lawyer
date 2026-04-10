import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../../core/errors/api_exception.dart';
import '../../domain/entities/document.dart';
import '../../domain/usecases/get-document-file-use-case.dart';

class DocumentViewerController extends ChangeNotifier {
  DocumentViewerController({
    required Document document,
    required GetDocumentFileUseCase getDocumentFileUseCase,
  })  : _document = document,
        _getDocumentFileUseCase = getDocumentFileUseCase;

  final Document _document;
  final GetDocumentFileUseCase _getDocumentFileUseCase;

  bool _isLoading = false;
  String? _errorMessage;
  String? _localFilePath;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get localFilePath => _localFilePath;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (!_document.isPdf) {
        _errorMessage = 'This document is not stored as PDF yet.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final documentFile = await _getDocumentFileUseCase.execute(
        documentId: _document.id,
        fileName: _document.originalName,
        fileType: _document.fileType,
      );
      final file = File(
        '${Directory.systemTemp.path}/${_safeFileName(documentFile.fileName)}',
      );

      await file.writeAsBytes(documentFile.bytes, flush: true);
      _localFilePath = file.path;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'We could not open the document right now.';
    }

    _isLoading = false;
    notifyListeners();
  }

  String _safeFileName(String fileName) {
    final normalized = fileName.trim().replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');

    if (normalized.toLowerCase().endsWith('.pdf')) {
      return normalized;
    }

    return '$normalized.pdf';
  }
}
