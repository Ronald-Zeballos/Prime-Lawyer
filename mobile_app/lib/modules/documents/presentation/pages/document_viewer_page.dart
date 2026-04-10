import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:provider/provider.dart';

import '../../../../shared/localization/app_strings_context.dart';
import '../../../legal_ai/presentation/pages/document_analysis_page.dart';
import '../../domain/entities/document.dart';
import '../../domain/usecases/get-document-file-use-case.dart';
import '../controllers/document_viewer_controller.dart';

class DocumentViewerPage extends StatelessWidget {
  const DocumentViewerPage({
    super.key,
    required this.document,
  });

  final Document document;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DocumentViewerController>(
      create: (context) => DocumentViewerController(
        document: document,
        getDocumentFileUseCase: context.read<GetDocumentFileUseCase>(),
      )..load(),
      child: _DocumentViewerView(document: document),
    );
  }
}

class _DocumentViewerView extends StatelessWidget {
  const _DocumentViewerView({
    required this.document,
  });

  final Document document;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DocumentViewerController>();
    final strings = context.strings;

    return Scaffold(
      appBar: AppBar(
        title: Text(document.originalName),
      ),
      bottomNavigationBar: controller.isLoading || controller.errorMessage != null
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: FilledButton.icon(
                onPressed: () => _showAnalysisPreviewInfo(context),
                icon: const Icon(Icons.auto_awesome_rounded),
                label: Text(strings.analyzeDocument),
              ),
            ),
      body: Builder(
        builder: (context) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  controller.errorMessage!,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (controller.localFilePath == null) {
            return Center(
              child: Text(strings.analysisUnavailable),
            );
          }

          return PDFView(
            filePath: controller.localFilePath!,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: true,
            pageFling: true,
          );
        },
      ),
    );
  }

  Future<void> _showAnalysisPreviewInfo(BuildContext context) {
    final strings = context.strings;

    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.analysisPreviewTitle,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(strings.analysisPreviewInfoDescription),
                const SizedBox(height: 16),
                _InfoBullet(text: strings.analysisPreviewInfoStepOne),
                _InfoBullet(text: strings.analysisPreviewInfoStepTwo),
                _InfoBullet(text: strings.analysisPreviewInfoStepThree),
                _InfoBullet(text: strings.analysisPreviewInfoStepFour),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => DocumentAnalysisPage(document: document),
                      ),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(strings.analysisPreviewContinueAction),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoBullet extends StatelessWidget {
  const _InfoBullet({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
