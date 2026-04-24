import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../shared/localization/app_strings_context.dart';
import '../../../../shared/widgets/prime_status_chip.dart';
import '../../../../shared/widgets/prime_surface_card.dart';
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

    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      onTap: onTap,
      child: PrimeSurfaceCard(
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
                TextButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.arrow_outward_rounded),
                  label: Text(strings.openCaseFileAction),
                ),
              ],
            ),
            if ((caseFile.description ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                caseFile.description!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
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
                PrimeStatusChip.neutral(caseFile.processType),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
