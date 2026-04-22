import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../../core/errors/api_exception.dart';
import '../../domain/entities/generated_contract.dart';
import '../../domain/usecases/get_generated_contract_pdf_use_case.dart';

class GeneratedContractViewerController extends ChangeNotifier {
  GeneratedContractViewerController({
    required GeneratedContract contract,
    required GetGeneratedContractPdfUseCase getGeneratedContractPdfUseCase,
  })  : _contract = contract,
        _getGeneratedContractPdfUseCase = getGeneratedContractPdfUseCase;

  final GeneratedContract _contract;
  final GetGeneratedContractPdfUseCase _getGeneratedContractPdfUseCase;

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
      final contractFile = await _getGeneratedContractPdfUseCase.execute(
        contractInstanceId: _contract.id,
        fileName: _contract.fileName,
      );
      final file = File(
        '${Directory.systemTemp.path}/${_safeFileName(contractFile.fileName)}',
      );

      await file.writeAsBytes(contractFile.bytes, flush: true);
      _localFilePath = file.path;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'We could not open the generated contract right now.';
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
