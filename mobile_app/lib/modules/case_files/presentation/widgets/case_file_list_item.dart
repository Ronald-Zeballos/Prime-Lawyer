import 'package:flutter/material.dart';

import '../../../../shared/localization/app_strings_context.dart';
import '../../domain/entities/case_file.dart';

class CaseFileListItem extends StatelessWidget {
  const CaseFileListItem({
    super.key,
    required this.caseFile,
    required this.onTap,
  });

  final CaseFile caseFile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                caseFile.internalCode,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(caseFile.title),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(
                    label: strings.caseStatus(caseFile.status),
                    backgroundColor: _statusPalette(caseFile.status).background,
                    foregroundColor: _statusPalette(caseFile.status).foreground,
                  ),
                  _InfoChip(label: caseFile.processType),
                  _InfoChip(
                    label: strings.knowledgeStatus(caseFile.knowledgeStatus),
                  ),
                  _InfoChip(
                    label: strings.confidentialityLevel(
                      caseFile.confidentialityLevel,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
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
