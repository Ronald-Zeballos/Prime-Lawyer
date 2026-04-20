import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../shared/localization/app_strings_context.dart';
import '../../../legal_ai/presentation/pages/contextual_legal_consultation_page.dart';
import '../../../documents/presentation/pages/documents_page.dart';
import '../../domain/usecases/get_case_file_detail_use_case.dart';
import '../controllers/case_file_detail_controller.dart';

class CaseFileDetailPage extends StatelessWidget {
  const CaseFileDetailPage({
    super.key,
    required this.caseFileId,
  });

  final String caseFileId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CaseFileDetailController>(
      create: (context) => CaseFileDetailController(
        getCaseFileDetailUseCase: context.read<GetCaseFileDetailUseCase>(),
      )..load(caseFileId),
      child: const _CaseFileDetailView(),
    );
  }
}

class _CaseFileDetailView extends StatelessWidget {
  const _CaseFileDetailView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CaseFileDetailController>();
    final caseFile = controller.caseFile;
    final strings = context.strings;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.caseFileDetailTitle),
      ),
      body: Builder(
        builder: (context) {
          if (controller.isLoading && caseFile == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.errorMessage != null && caseFile == null) {
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

          if (caseFile == null) {
            return Center(
              child: Text(strings.caseFileUnavailable),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        caseFile.displayLabel,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      if ((caseFile.description ?? '').isNotEmpty)
                        Text(caseFile.description!),
                      if ((caseFile.description ?? '').isNotEmpty)
                        const SizedBox(height: 16),
                      const SizedBox(height: 16),
                      _DetailLine(
                        label: strings.processTypeDetailLabel,
                        value: caseFile.processType,
                      ),
                      _DetailLine(
                        label: strings.statusLabel,
                        value: strings.caseStatus(caseFile.status),
                      ),
                      _DetailLine(
                        label: strings.confidentialityLabel,
                        value: strings.confidentialityLevel(
                          caseFile.confidentialityLevel,
                        ),
                      ),
                      _DetailLine(
                        label: strings.caseVisibilityLabel,
                        value: strings.caseVisibility(caseFile.visibility),
                      ),
                      _DetailLine(
                        label: strings.knowledgeStatusLabel,
                        value: strings.knowledgeStatus(caseFile.knowledgeStatus),
                      ),
                      _DetailLine(
                        label: strings.openedAtLabel,
                        value: strings.formatDateTime(caseFile.openedAt),
                      ),
                      _DetailLine(
                        label: strings.closedAtLabel,
                        value: caseFile.closedAt == null
                            ? strings.notClosedYet
                            : strings.formatDateTime(caseFile.closedAt!),
                      ),
                      const SizedBox(height: 10),
                      FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                            AppRoutes.documents,
                            arguments: DocumentsPageArgs(
                              caseFileId: caseFile.id,
                              caseFileTitle: caseFile.displayLabel,
                            ),
                          );
                        },
                        icon: const Icon(Icons.description_outlined),
                        label: Text(strings.openDocuments),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                            AppRoutes.legalAiConsultation,
                            arguments: ContextualLegalConsultationPageArgs(
                              preselectedCaseFileId: caseFile.id,
                            ),
                          );
                        },
                        icon: const Icon(Icons.auto_awesome_rounded),
                        label: Text(strings.askAiAboutCase),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(value),
        ],
      ),
    );
  }
}
