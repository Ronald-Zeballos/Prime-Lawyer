import 'package:flutter/material.dart';

import '../../../../shared/localization/app_strings_context.dart';
import '../../domain/entities/case_file.dart';

class CaseFileListItem extends StatelessWidget {
  const CaseFileListItem({
    super.key,
    required this.caseFile,
    required this.clientLabel,
    required this.onTap,
  });

  final CaseFile caseFile;
  final String clientLabel;
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
              Text(caseFile.subject),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(label: clientLabel),
                  _InfoChip(label: strings.caseStatus(caseFile.status)),
                  _InfoChip(label: caseFile.processType),
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
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE9EEE7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label),
    );
  }
}
