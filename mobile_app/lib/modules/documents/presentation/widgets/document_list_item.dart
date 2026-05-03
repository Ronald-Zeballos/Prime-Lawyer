import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../shared/localization/app_strings_context.dart';
import '../../../../shared/widgets/prime_status_chip.dart';
import '../../../../shared/widgets/prime_surface_card.dart';
import '../../domain/entities/document.dart';

class DocumentListItem extends StatelessWidget {
  const DocumentListItem({
    super.key,
    required this.document,
    required this.onOpen,
    required this.onAskAi,
  });

  final Document document;
  final VoidCallback onOpen;
  final VoidCallback onAskAi;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return PrimeSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            document.originalName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              PrimeStatusChip.neutral(document.fileType),
              PrimeStatusChip.neutral(strings.ocrStatus(document.ocrStatus)),
              PrimeStatusChip.accent(document.uploadSource),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            strings.uploadedAt(strings.formatDateTime(document.uploadedAt)),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (document.ocrProcessedAt != null) ...[
            const SizedBox(height: 4),
            Text(
              strings.ocrProcessedAt(
                strings.formatDateTime(document.ocrProcessedAt!),
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (document.hasOcrText) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.appBackground,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.softBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.ocrTextPreviewTitle,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    document.ocrPreview,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.tonalIcon(
                onPressed: document.isPdf
                    ? onOpen
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(strings.pdfPreviewOnlyMessage),
                          ),
                        );
                      },
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: Text(
                  document.isPdf ? strings.openPdfAction : strings.pdfOnlyLabel,
                ),
              ),
              OutlinedButton.icon(
                onPressed: onAskAi,
                icon: const Icon(Icons.auto_awesome_rounded),
                label: Text(strings.askAiAboutDocument),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
