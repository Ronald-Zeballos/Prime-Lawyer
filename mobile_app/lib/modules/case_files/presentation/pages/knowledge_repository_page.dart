import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../shared/localization/app_strings_context.dart';
import '../../../../shared/providers/session_provider.dart';
import '../../../../shared/widgets/prime_brand_app_bar.dart';
import '../../../../shared/widgets/prime_empty_state.dart';
import '../../../../shared/widgets/prime_page_scaffold.dart';
import '../../../../shared/widgets/prime_search_field.dart';
import '../../../../shared/widgets/prime_status_chip.dart';
import '../../../../shared/widgets/prime_surface_card.dart';
import '../../domain/entities/case_file.dart';
import '../../domain/usecases/get_collaborative_repository_cases_use_case.dart';
import 'case_file_detail_page.dart';
import '../controllers/knowledge_repository_controller.dart';
import 'knowledge_repository_summary_page.dart';

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

class _KnowledgeRepositoryView extends StatefulWidget {
  const _KnowledgeRepositoryView();

  @override
  State<_KnowledgeRepositoryView> createState() =>
      _KnowledgeRepositoryViewState();
}

class _KnowledgeRepositoryViewState extends State<_KnowledgeRepositoryView> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<KnowledgeRepositoryController>();
    final strings = context.strings;
    final currentUserId =
        context.watch<SessionProvider>().currentUser?.id.trim() ?? '';

    if (_searchController.text != controller.searchTerm) {
      _searchController.value = TextEditingValue(
        text: controller.searchTerm,
        selection:
            TextSelection.collapsed(offset: controller.searchTerm.length),
      );
    }

    return PrimePageScaffold(
      appBar: PrimeBrandAppBar(
        title: strings.knowledgeRepositoryTitle,
        leadingIcon: Icons.arrow_back_rounded,
        leadingTooltip: strings.isSpanish ? 'Volver' : 'Back',
        actions: [
          PrimeHeaderIconButton(
            icon: Icons.refresh_rounded,
            tooltip: strings.refreshKnowledgeRepository,
            onPressed: controller.isLoading ? null : controller.refresh,
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (controller.isLoading && !controller.hasCaseFiles) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.pagePadding,
                8,
                AppTheme.pagePadding,
                40,
              ),
              children: [
                PrimeSurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.isSpanish
                            ? 'Repositorio colaborativo'
                            : 'Collaborative repository',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        strings.isSpanish
                            ? 'Consulta casos publicados y vuelve al expediente real cuando te pertenezca.'
                            : 'Review published cases and jump back to the real case file when it belongs to you.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 18),
                      PrimeSearchField(
                        controller: _searchController,
                        hintText: strings.knowledgeRepositorySearchHint,
                        onChanged: controller.onSearchChanged,
                        onClear: () {
                          _searchController.clear();
                          controller.onSearchChanged('');
                        },
                      ),
                    ],
                  ),
                ),
                if (controller.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  _RepositoryErrorBanner(message: controller.errorMessage!),
                ],
                const SizedBox(height: AppTheme.sectionSpacing),
                if (!controller.hasCaseFiles)
                  PrimeSurfaceCard(
                    child: PrimeEmptyState(
                      icon: Icons.library_books_outlined,
                      title: strings.knowledgeRepositoryEmptyTitle,
                      description: strings.knowledgeRepositoryEmptyDescription,
                    ),
                  )
                else
                  for (final caseFile in controller.caseFiles) ...[
                    _RepositoryCaseCard(
                      caseFile: caseFile,
                      isOwnedByCurrentUser:
                          caseFile.ownerUserId.trim() == currentUserId,
                      onViewSummary: () => _openRepositorySummary(
                        context,
                        caseFile: caseFile,
                        isOwnedByCurrentUser:
                            caseFile.ownerUserId.trim() == currentUserId,
                      ),
                      onOpenOwnedCaseFile:
                          caseFile.ownerUserId.trim() == currentUserId
                              ? () => _openOwnedCaseFile(context, caseFile)
                              : null,
                    ),
                    const SizedBox(height: 14),
                  ],
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openOwnedCaseFile(
    BuildContext context,
    CaseFile caseFile,
  ) async {
    final strings = context.strings;
    final caseFileId = caseFile.id.trim();

    if (caseFileId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.repositoryCaseOpenFailed)),
      );
      return;
    }

    try {
      await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute<void>(
          builder: (_) => CaseFileDetailPage(caseFileId: caseFileId),
        ),
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.repositoryCaseOpenFailed)),
      );
    }
  }

  Future<void> _openRepositorySummary(
    BuildContext context, {
    required CaseFile caseFile,
    required bool isOwnedByCurrentUser,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => KnowledgeRepositorySummaryPage(
          caseFile: caseFile,
          isOwnedByCurrentUser: isOwnedByCurrentUser,
          ownedCaseFileId: isOwnedByCurrentUser ? caseFile.id : null,
        ),
      ),
    );
  }
}

class _RepositoryCaseCard extends StatelessWidget {
  const _RepositoryCaseCard({
    required this.caseFile,
    required this.isOwnedByCurrentUser,
    required this.onViewSummary,
    required this.onOpenOwnedCaseFile,
  });

  final CaseFile caseFile;
  final bool isOwnedByCurrentUser;
  final VoidCallback onViewSummary;
  final VoidCallback? onOpenOwnedCaseFile;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return PrimeSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      caseFile.internalCode,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      caseFile.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              PrimeStatusChip.knowledgeStatus(
                status: 'PUBLISHED',
                label: strings.knowledgeRepositoryPublishedBadge,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if ((caseFile.description ?? '').trim().isNotEmpty)
            Text(
              caseFile.description!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              PrimeStatusChip.caseStatus(
                status: caseFile.status,
                label: strings.caseStatus(caseFile.status),
              ),
              PrimeStatusChip.confidentiality(
                level: caseFile.confidentialityLevel,
                label: strings.confidentialityLevel(
                  caseFile.confidentialityLevel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '${strings.closedAtLabel}: ${caseFile.closedAt == null ? strings.notClosedYet : strings.formatDateTime(caseFile.closedAt!)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            '${strings.publishedAtLabel}: ${caseFile.publishedAt == null ? strings.notPublishedYet : strings.formatDateTime(caseFile.publishedAt!)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.tonalIcon(
                onPressed: onViewSummary,
                icon: const Icon(Icons.article_outlined),
                label: Text(strings.repositoryViewSummaryAction),
              ),
              if (isOwnedByCurrentUser)
                OutlinedButton.icon(
                  onPressed: onOpenOwnedCaseFile,
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: Text(strings.openOwnedRepositoryCaseAction),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RepositoryErrorBanner extends StatelessWidget {
  const _RepositoryErrorBanner({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.errorSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.error.withValues(alpha: 0.16)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.error,
              ),
        ),
      ),
    );
  }
}
