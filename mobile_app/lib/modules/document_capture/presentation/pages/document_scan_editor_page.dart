import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/localization/app_strings_context.dart';
import '../../domain/entities/captured_document.dart';
import '../../domain/entities/document_capture_progress.dart';
import '../controllers/document_scan_editor_controller.dart';
import '../widgets/document_scan_page_card.dart';

class DocumentScanEditorPage extends StatelessWidget {
  const DocumentScanEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DocumentScanEditorController>();
    final strings = context.strings;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.scanDocumentEditorTitle),
        actions: [
          IconButton(
            onPressed: controller.isProcessing || controller.isAddingPages
                ? null
                : controller.addMorePages,
            tooltip: strings.scanAddPage,
            icon: controller.isAddingPages
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add_a_photo_outlined),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8E1D7),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.scanPagesCount(controller.draft.pages.length),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(strings.scanDocumentEditorDescription),
                      const SizedBox(height: 6),
                      Text(
                        strings.scanReorderHint,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed:
                            controller.isProcessing || controller.isAddingPages
                                ? null
                                : controller.addMorePages,
                        icon: const Icon(Icons.note_add_outlined),
                        label: Text(strings.scanAddPage),
                      ),
                    ],
                  ),
                ),
              ),
              if (controller.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBE7E5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      controller.errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: controller.hasPages
                    ? ReorderableListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                        itemCount: controller.draft.pages.length,
                        onReorder: controller.reorderPages,
                        itemBuilder: (context, index) {
                          final page = controller.draft.pages[index];

                          return DocumentScanPageCard(
                            page: page,
                            pageNumber: index + 1,
                            canDelete: controller.draft.pages.length > 1,
                            previewUnavailableLabel:
                                strings.scanPreviewUnavailable,
                            rotateLabel: strings.scanRotatePage,
                            deleteLabel: strings.scanDeletePage,
                            pageLabel: strings.scanPageLabelPrefix,
                            onRotate: () => controller.rotatePage(page.id),
                            onDelete: () => controller.removePage(page.id),
                          );
                        },
                      )
                    : Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                strings.scanNoPagesError,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              FilledButton.icon(
                                onPressed: controller.isProcessing ||
                                        controller.isAddingPages
                                    ? null
                                    : controller.addMorePages,
                                icon:
                                    const Icon(Icons.document_scanner_outlined),
                                label: Text(strings.scanAddPage),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
          if (controller.isProcessing)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.35),
                child: Center(
                  child: Container(
                    width: 320,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: _ProgressContent(
                      progress: controller.progress,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: FilledButton.icon(
          onPressed: controller.isProcessing || !controller.hasPages
              ? null
              : () async {
                  final document = await context
                      .read<DocumentScanEditorController>()
                      .finalizeDocument();

                  if (!context.mounted || document == null) {
                    return;
                  }

                  Navigator.of(context).pop<CapturedDocument>(document);
                },
          icon: const Icon(Icons.picture_as_pdf_outlined),
          label: Text(strings.scanGeneratePdf),
        ),
      ),
    );
  }
}

class _ProgressContent extends StatelessWidget {
  const _ProgressContent({
    required this.progress,
  });

  final DocumentCaptureProgress? progress;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final resolvedProgress = progress;
    final fraction = resolvedProgress?.fraction ?? 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          strings.scanProcessingTitle,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(value: fraction == 0 ? null : fraction),
        const SizedBox(height: 12),
        Text(
          _progressLabel(
            context,
            resolvedProgress,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _progressLabel(
    BuildContext context,
    DocumentCaptureProgress? progress,
  ) {
    final strings = context.strings;

    if (progress == null) {
      return strings.scanPreparingProgress;
    }

    switch (progress.stage) {
      case DocumentCaptureStage.optimizingPages:
        return strings.scanOptimizingProgress(
          progress.completedSteps.clamp(1, progress.totalSteps),
          progress.totalSteps == 0 ? 0 : ((progress.totalSteps - 1) / 2).ceil(),
        );
      case DocumentCaptureStage.recognizingText:
        final pages = progress.totalSteps == 0
            ? 0
            : ((progress.totalSteps - 1) / 2).ceil();
        final current = progress.completedSteps - pages;

        return strings.scanOcrProgress(
          current.clamp(1, pages),
          pages,
        );
      case DocumentCaptureStage.generatingPdf:
        return strings.scanGeneratingPdfProgress;
      case DocumentCaptureStage.completed:
        return strings.scanReadyProgress;
    }
  }
}
