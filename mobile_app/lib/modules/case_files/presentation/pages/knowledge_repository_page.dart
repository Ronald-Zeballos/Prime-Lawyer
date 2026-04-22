import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../shared/localization/app_strings_context.dart';
import '../../../../shared/providers/session_provider.dart';
import '../../domain/entities/case_file.dart';
import '../../domain/usecases/get_collaborative_repository_cases_use_case.dart';
import '../controllers/knowledge_repository_controller.dart';

class KnowledgeRepositoryPage extends StatelessWidget {
  const KnowledgeRepositoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<KnowledgeRepositoryController>(
      create: (context) => KnowledgeRepositoryController(
        getCollaborativeRepositoryCasesUseCase:
            context.read<GetCollaborativeRepositoryCasesUseCase>(),
      )..loadInitialData(),
      child: const _KnowledgeRepositoryView(),
    );
  }
}

class _KnowledgeRepositoryView extends StatelessWidget {
  const _KnowledgeRepositoryView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<KnowledgeRepositoryController>();
    final strings = context.strings;
    final currentUserId =
        context.watch<SessionProvider>().currentUser?.id.trim() ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.knowledgeRepositoryTitle),
        actions: [
          IconButton(
            onPressed: controller.isLoading ? null : controller.refresh,
            tooltip: strings.refreshKnowledgeRepository,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: TextField(
              onChanged: controller.onSearchChanged,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded),
                labelText: strings.knowledgeRepositorySearchLabel,
                hintText: strings.knowledgeRepositorySearchHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
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
                if (controller.isLoading && !controller.hasCaseFiles) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!controller.hasCaseFiles) {
                  return RefreshIndicator(
                    onRefresh: controller.refresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      children: [
                        const SizedBox(height: 80),
                        Icon(
                          Icons.library_books_outlined,
                          size: 56,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          strings.knowledgeRepositoryEmptyTitle,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          strings.knowledgeRepositoryEmptyDescription,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.refresh,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                    itemCount: controller.caseFiles.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final caseFile = controller.caseFiles[index];
                      final isOwnedByCurrentUser =
                          caseFile.ownerUserId.trim() == currentUserId;

                      return _RepositoryCaseCard(
                        caseFile: caseFile,
                        isOwnedByCurrentUser: isOwnedByCurrentUser,
                        onOpenSummary: () => _showRepositorySummary(
                          context,
                          caseFile: caseFile,
                          isOwnedByCurrentUser: isOwnedByCurrentUser,
                        ),
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

  Future<void> _showRepositorySummary(
    BuildContext context, {
    required CaseFile caseFile,
    required bool isOwnedByCurrentUser,
  }) {
    final parentContext = context;
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
                  caseFile.displayLabel,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                if ((caseFile.description ?? '').trim().isNotEmpty)
                  Text(caseFile.description!),
                if ((caseFile.description ?? '').trim().isNotEmpty)
                  const SizedBox(height: 16),
                _RepositorySummaryLine(
                  label: strings.processTypeDetailLabel,
                  value: caseFile.processType,
                ),
                _RepositorySummaryLine(
                  label: strings.statusLabel,
                  value: strings.caseStatus(caseFile.status),
                ),
                _RepositorySummaryLine(
                  label: strings.knowledgeStatusLabel,
                  value: strings.knowledgeStatus(caseFile.knowledgeStatus),
                ),
                _RepositorySummaryLine(
                  label: strings.closedAtLabel,
                  value: caseFile.closedAt == null
                      ? strings.notClosedYet
                      : strings.formatDateTime(caseFile.closedAt!),
                ),
                _RepositorySummaryLine(
                  label: strings.publishedAtLabel,
                  value: caseFile.publishedAt == null
                      ? strings.notPublishedYet
                      : strings.formatDateTime(caseFile.publishedAt!),
                ),
                const SizedBox(height: 18),
                if (isOwnedByCurrentUser)
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(parentContext).pushNamed(
                        AppRoutes.caseFileDetail,
                        arguments: caseFile.id,
                      );
                    },
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: Text(strings.openOwnedRepositoryCaseAction),
                  )
                else
                  Text(
                    strings.repositorySharedCaseNotice,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RepositoryCaseCard extends StatelessWidget {
  const _RepositoryCaseCard({
    required this.caseFile,
    required this.isOwnedByCurrentUser,
    required this.onOpenSummary,
  });

  final CaseFile caseFile;
  final bool isOwnedByCurrentUser;
  final VoidCallback onOpenSummary;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Card(
      child: InkWell(
        onTap: onOpenSummary,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      caseFile.internalCode,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F0E5),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      strings.knowledgeRepositoryPublishedBadge,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F6A3A),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                caseFile.title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              if ((caseFile.description ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  caseFile.description!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _RepositoryChip(label: caseFile.processType),
                  _RepositoryChip(label: strings.caseStatus(caseFile.status)),
                  _RepositoryChip(
                    label: strings.knowledgeStatus(caseFile.knowledgeStatus),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                caseFile.closedAt == null
                    ? strings.notClosedYet
                    : strings.repositoryClosedOn(
                        strings.formatShortDate(caseFile.closedAt!),
                      ),
              ),
              const SizedBox(height: 4),
              Text(
                caseFile.publishedAt == null
                    ? strings.notPublishedYet
                    : strings.repositoryPublishedOn(
                        strings.formatShortDate(caseFile.publishedAt!),
                      ),
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: onOpenSummary,
                  icon: Icon(
                    isOwnedByCurrentUser
                        ? Icons.open_in_new_rounded
                        : Icons.visibility_outlined,
                  ),
                  label: Text(
                    isOwnedByCurrentUser
                        ? strings.openOwnedRepositoryCaseAction
                        : strings.repositoryViewSummaryAction,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RepositoryChip extends StatelessWidget {
  const _RepositoryChip({
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

class _RepositorySummaryLine extends StatelessWidget {
  const _RepositorySummaryLine({
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
