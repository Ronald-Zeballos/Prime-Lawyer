import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../shared/localization/app_strings.dart';
import '../../../../shared/localization/app_strings_context.dart';
import '../../../documents/presentation/pages/documents_page.dart';
import '../../../legal_ai/presentation/pages/contextual_legal_consultation_page.dart';
import '../../domain/entities/case_file.dart';
import '../../domain/usecases/change_case_file_status_use_case.dart';
import '../../domain/usecases/get_case_file_detail_use_case.dart';
import '../../domain/usecases/update_case_knowledge_publication_use_case.dart';
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
        changeCaseFileStatusUseCase:
            context.read<ChangeCaseFileStatusUseCase>(),
        updateCaseKnowledgePublicationUseCase:
            context.read<UpdateCaseKnowledgePublicationUseCase>(),
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
        actions: [
          IconButton(
            onPressed: controller.isBusy || caseFile == null
                ? null
                : () => controller.load(caseFile.id),
            tooltip: strings.refreshCaseFiles,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
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
              if (controller.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              caseFile.displayLabel,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          _StatusChip(
                              label: strings.caseStatus(caseFile.status)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if ((caseFile.description ?? '').isNotEmpty)
                        Text(caseFile.description!),
                      if ((caseFile.description ?? '').isNotEmpty)
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
                        value:
                            strings.knowledgeStatus(caseFile.knowledgeStatus),
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
                      _DetailLine(
                        label: strings.publishedAtLabel,
                        value: caseFile.publishedAt == null
                            ? strings.notPublishedYet
                            : strings.formatDateTime(caseFile.publishedAt!),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          FilledButton.icon(
                            onPressed: controller.isBusy
                                ? null
                                : () {
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
                          OutlinedButton.icon(
                            onPressed: controller.isBusy
                                ? null
                                : () {
                                    Navigator.of(context).pushNamed(
                                      AppRoutes.legalAiConsultation,
                                      arguments:
                                          ContextualLegalConsultationPageArgs(
                                        preselectedCaseFileId: caseFile.id,
                                      ),
                                    );
                                  },
                            icon: const Icon(Icons.auto_awesome_rounded),
                            label: Text(strings.askAiAboutCase),
                          ),
                          OutlinedButton.icon(
                            onPressed: controller.isBusy
                                ? null
                                : () => _showStatusSheet(context, caseFile),
                            icon: const Icon(Icons.swap_horiz_rounded),
                            label: Text(strings.changeCaseStatusAction),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _KnowledgeRepositoryCard(
                caseFile: caseFile,
                isBusy: controller.isBusy,
                onPublish: () => _handlePublication(context, publish: true),
                onUnpublish: () => _handlePublication(context, publish: false),
                onOpenRepository: () {
                  Navigator.of(context)
                      .pushNamed(AppRoutes.knowledgeRepository);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showStatusSheet(BuildContext context, CaseFile caseFile) async {
    final selectedStatus = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return _CaseStatusSheet(currentStatus: caseFile.status);
      },
    );

    if (!context.mounted ||
        selectedStatus == null ||
        selectedStatus == caseFile.status) {
      return;
    }

    await _handleStatusChange(context, selectedStatus);
  }

  Future<void> _handleStatusChange(
    BuildContext context,
    String status,
  ) async {
    final controller = context.read<CaseFileDetailController>();
    final strings = context.strings;
    final success = await controller.changeStatus(status);

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? strings.caseStatusUpdated(strings.caseStatus(status))
              : controller.errorMessage ?? strings.caseStatusUpdateFailed,
        ),
      ),
    );
  }

  Future<void> _handlePublication(
    BuildContext context, {
    required bool publish,
  }) async {
    final controller = context.read<CaseFileDetailController>();
    final strings = context.strings;
    final success = await controller.updateKnowledgePublication(publish);

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? publish
                  ? strings.casePublishedToRepository
                  : strings.caseRemovedFromRepository
              : controller.errorMessage ??
                  (publish
                      ? strings.casePublicationFailed
                      : strings.caseUnpublishFailed),
        ),
      ),
    );
  }
}

class _CaseStatusSheet extends StatefulWidget {
  const _CaseStatusSheet({
    required this.currentStatus,
  });

  final String currentStatus;

  @override
  State<_CaseStatusSheet> createState() => _CaseStatusSheetState();
}

class _CaseStatusSheetState extends State<_CaseStatusSheet> {
  static const List<String> _availableStatuses = <String>[
    'OPEN',
    'IN_PROGRESS',
    'CLOSED',
    'ARCHIVED',
  ];

  late String _selectedStatus = widget.currentStatus;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.changeCaseStatusAction,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(strings.changeCaseStatusDescription),
            const SizedBox(height: 16),
            for (final status in _availableStatuses)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  tileColor: const Color(0xFFF7F2EA),
                  selected: _selectedStatus == status,
                  title: Text(strings.caseStatus(status)),
                  leading: Icon(
                    _selectedStatus == status
                        ? Icons.check_circle_rounded
                        : Icons.flag_outlined,
                  ),
                  trailing: _selectedStatus == status
                      ? const Icon(Icons.radio_button_checked_rounded)
                      : const Icon(Icons.radio_button_off_rounded),
                  onTap: () {
                    setState(() {
                      _selectedStatus = status;
                    });
                  },
                ),
              ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _selectedStatus == widget.currentStatus
                  ? null
                  : () => Navigator.of(context).pop(_selectedStatus),
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: Text(strings.changeCaseStatusAction),
            ),
          ],
        ),
      ),
    );
  }
}

class _KnowledgeRepositoryCard extends StatelessWidget {
  const _KnowledgeRepositoryCard({
    required this.caseFile,
    required this.isBusy,
    required this.onPublish,
    required this.onUnpublish,
    required this.onOpenRepository,
  });

  final CaseFile caseFile;
  final bool isBusy;
  final Future<void> Function() onPublish;
  final Future<void> Function() onUnpublish;
  final VoidCallback onOpenRepository;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.knowledgeRepositorySectionTitle,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(_description(strings)),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _StatusChip(label: strings.caseStatus(caseFile.status)),
                _StatusChip(
                  label: strings.knowledgeStatus(caseFile.knowledgeStatus),
                ),
                _StatusChip(
                  label: strings.caseVisibility(caseFile.visibility),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (caseFile.knowledgeStatus == 'ELIGIBLE')
                  FilledButton.icon(
                    onPressed: isBusy
                        ? null
                        : () async {
                            await onPublish();
                          },
                    icon: const Icon(Icons.publish_rounded),
                    label: Text(strings.publishCaseAction),
                  ),
                if (caseFile.knowledgeStatus == 'PUBLISHED')
                  FilledButton.icon(
                    onPressed: isBusy
                        ? null
                        : () async {
                            await onUnpublish();
                          },
                    icon: const Icon(Icons.unpublished_rounded),
                    label: Text(strings.unpublishCaseAction),
                  ),
                if (caseFile.knowledgeStatus != 'PUBLISHED' &&
                    caseFile.status != 'CLOSED' &&
                    caseFile.status != 'ARCHIVED')
                  OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.lock_clock_outlined),
                    label: Text(strings.closeCaseToPublishAction),
                  ),
                OutlinedButton.icon(
                  onPressed: onOpenRepository,
                  icon: const Icon(Icons.library_books_outlined),
                  label: Text(strings.openKnowledgeRepository),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _description(AppStrings strings) {
    switch (caseFile.knowledgeStatus) {
      case 'PUBLISHED':
        final publishedAt = caseFile.publishedAt;

        if (publishedAt == null) {
          return strings.caseAlreadyPublishedDescription;
        }

        return strings.casePublishedDescription(
          strings.formatShortDate(publishedAt),
        );
      case 'ELIGIBLE':
        return strings.caseEligibleForRepositoryDescription;
      case 'EXCLUDED':
        return strings.caseExcludedFromRepositoryDescription;
      default:
        return strings.caseNotReadyForRepositoryDescription;
    }
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF2E4D2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label),
    );
  }
}
