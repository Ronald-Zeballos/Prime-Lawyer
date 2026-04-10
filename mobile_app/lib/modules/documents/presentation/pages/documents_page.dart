import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/localization/app_strings_context.dart';
import '../../../document_capture/domain/usecases/capture_document_from_camera_use_case.dart';
import '../../../document_capture/domain/usecases/pick_document_use_case.dart';
import '../../domain/usecases/get_case_documents_use_case.dart';
import '../../domain/usecases/register_document_use_case.dart';
import '../controllers/documents_controller.dart';
import 'document_viewer_page.dart';
import '../widgets/document_list_item.dart';
import '../widgets/register_document_sheet.dart';

class DocumentsPageArgs {
  const DocumentsPageArgs({
    required this.caseFileId,
    required this.caseFileTitle,
  });

  final String caseFileId;
  final String caseFileTitle;
}

class DocumentsPage extends StatelessWidget {
  const DocumentsPage({
    super.key,
    required this.args,
  });

  final DocumentsPageArgs args;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DocumentsController>(
      create: (context) => DocumentsController(
        caseFileId: args.caseFileId,
        getCaseDocumentsUseCase: context.read<GetCaseDocumentsUseCase>(),
        registerDocumentUseCase: context.read<RegisterDocumentUseCase>(),
        pickDocumentUseCase: context.read<PickDocumentUseCase>(),
        captureDocumentFromCameraUseCase:
            context.read<CaptureDocumentFromCameraUseCase>(),
      )..loadDocuments(),
      child: _DocumentsView(args: args),
    );
  }
}

class _DocumentsView extends StatelessWidget {
  const _DocumentsView({
    required this.args,
  });

  final DocumentsPageArgs args;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DocumentsController>();
    final strings = context.strings;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.documentsTitle),
        actions: [
          IconButton(
            onPressed: controller.isLoading ? null : controller.refresh,
            tooltip: strings.refreshDocuments,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openRegisterDocumentSheet(context),
        icon: const Icon(Icons.upload_file_rounded),
        label: Text(strings.upload),
      ),
      body: Column(
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
              child: Text(
                strings.caseFileNameLabel(args.caseFileTitle),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
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
            child: Builder(
              builder: (context) {
                if (controller.isLoading && !controller.hasDocuments) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!controller.hasDocuments) {
                  return RefreshIndicator(
                    onRefresh: controller.refresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      children: [
                        const SizedBox(height: 80),
                        Icon(
                          Icons.description_outlined,
                          size: 56,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          strings.noDocumentsTitle,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          strings.noDocumentsDescription,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.refresh,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    itemCount: controller.documents.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final document = controller.documents[index];

                      return DocumentListItem(
                        document: document,
                        onOpen: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => DocumentViewerPage(document: document),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openRegisterDocumentSheet(BuildContext context) {
    final controller = context.read<DocumentsController>();
    controller.clearError();

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ChangeNotifierProvider<DocumentsController>.value(
        value: controller,
        child: Consumer<DocumentsController>(
          builder: (context, value, _) => RegisterDocumentSheet(
            selectedDocument: value.selectedDocument,
            isSubmitting: value.isSubmitting,
            errorMessage: value.errorMessage,
            onPickDocument: value.pickDocument,
            onCaptureFromCamera: value.captureFromCamera,
            onSubmit: value.registerSelectedDocument,
            onClearSelection: value.clearSelection,
          ),
        ),
      ),
    );
  }
}
