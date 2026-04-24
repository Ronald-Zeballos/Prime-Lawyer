import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../shared/localization/app_strings_context.dart';
import '../../../../shared/widgets/prime_brand_app_bar.dart';
import '../../../../shared/widgets/prime_page_scaffold.dart';
import '../../../../shared/widgets/prime_status_chip.dart';
import '../../../../shared/widgets/prime_surface_card.dart';
import '../../domain/entities/case_file.dart';

class KnowledgeRepositorySummaryPage extends StatelessWidget {
  const KnowledgeRepositorySummaryPage({
    super.key,
    required this.caseFile,
    required this.isOwnedByCurrentUser,
    required this.onOpenCaseFile,
  });

  final CaseFile caseFile;
  final bool isOwnedByCurrentUser;
  final Future<void> Function() onOpenCaseFile;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return PrimePageScaffold(
      appBar: PrimeBrandAppBar(
        title: strings.repositoryViewSummaryAction,
        leadingIcon: Icons.arrow_back_rounded,
        leadingTooltip: strings.isSpanish ? 'Volver' : 'Back',
      ),
      body: ListView(
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
                  caseFile.displayLabel,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
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
                    PrimeStatusChip.knowledgeStatus(
                      status: caseFile.knowledgeStatus,
                      label: strings.knowledgeStatus(caseFile.knowledgeStatus),
                    ),
                    PrimeStatusChip.confidentiality(
                      level: caseFile.confidentialityLevel,
                      label: strings.confidentialityLevel(
                        caseFile.confidentialityLevel,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  strings.repositoryLegalSummaryTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  (caseFile.description ?? '').trim().isEmpty
                      ? strings.repositorySummaryUnavailable
                      : caseFile.description!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PrimeSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SummaryLine(
                  label: strings.repositoryOriginalCaseLabel,
                  value: caseFile.internalCode,
                ),
                _SummaryLine(
                  label: strings.processTypeDetailLabel,
                  value: caseFile.processType,
                ),
                _SummaryLine(
                  label: strings.statusLabel,
                  value: strings.caseStatus(caseFile.status),
                ),
                _SummaryLine(
                  label: strings.confidentialityLabel,
                  value: strings.confidentialityLevel(
                    caseFile.confidentialityLevel,
                  ),
                ),
                _SummaryLine(
                  label: strings.knowledgeStatusLabel,
                  value: strings.knowledgeStatus(caseFile.knowledgeStatus),
                ),
                _SummaryLine(
                  label: strings.openedAtLabel,
                  value: strings.formatDateTime(caseFile.openedAt),
                ),
                _SummaryLine(
                  label: strings.closedAtLabel,
                  value: caseFile.closedAt == null
                      ? strings.notClosedYet
                      : strings.formatDateTime(caseFile.closedAt!),
                ),
                _SummaryLine(
                  label: strings.publishedAtLabel,
                  value: caseFile.publishedAt == null
                      ? strings.notPublishedYet
                      : strings.formatDateTime(caseFile.publishedAt!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PrimeSurfaceCard(
            child: isOwnedByCurrentUser
                ? FilledButton.icon(
                    onPressed: onOpenCaseFile,
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: Text(strings.openOwnedRepositoryCaseAction),
                  )
                : Text(
                    strings.repositorySharedCaseNotice,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
