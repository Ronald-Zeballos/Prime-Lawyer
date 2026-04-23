import 'package:flutter/material.dart';

import '../../../../shared/localization/app_strings_context.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.repositoryViewSummaryAction),
      ),
      body: ListView(
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
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _SummaryChip(
                        label: strings.caseStatus(caseFile.status),
                        backgroundColor:
                            _statusPalette(caseFile.status).background,
                        foregroundColor:
                            _statusPalette(caseFile.status).foreground,
                      ),
                      _SummaryChip(
                        label: strings.confidentialityLevel(
                          caseFile.confidentialityLevel,
                        ),
                      ),
                      _SummaryChip(
                        label: strings.knowledgeStatus(caseFile.knowledgeStatus),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    strings.repositoryLegalSummaryTitle,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    (caseFile.description ?? '').trim().isEmpty
                        ? strings.repositorySummaryUnavailable
                        : caseFile.description!,
                  ),
                  const SizedBox(height: 18),
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
                  const SizedBox(height: 18),
                  if (isOwnedByCurrentUser)
                    FilledButton.icon(
                      onPressed: onOpenCaseFile,
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
      padding: const EdgeInsets.only(bottom: 12),
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

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    this.backgroundColor = const Color(0xFFF2E4D2),
    this.foregroundColor = const Color(0xFF4A4038),
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foregroundColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

({Color background, Color foreground}) _statusPalette(String status) {
  switch (status) {
    case 'OPEN':
      return (
        background: const Color(0xFFE3F2E7),
        foreground: const Color(0xFF1F6A3A),
      );
    case 'IN_PROGRESS':
      return (
        background: const Color(0xFFFFF1D6),
        foreground: const Color(0xFF8B5A00),
      );
    case 'CLOSED':
      return (
        background: const Color(0xFFE6ECF5),
        foreground: const Color(0xFF335C8A),
      );
    case 'ARCHIVED':
      return (
        background: const Color(0xFFEDE7E3),
        foreground: const Color(0xFF6A5B54),
      );
    default:
      return (
        background: const Color(0xFFF2E4D2),
        foreground: const Color(0xFF4A4038),
      );
  }
}
