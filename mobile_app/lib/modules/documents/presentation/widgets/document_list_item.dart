import 'package:flutter/material.dart';

import '../../../../shared/localization/app_strings_context.dart';
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              document.originalName,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _DocumentChip(label: document.fileType),
                _DocumentChip(label: strings.ocrStatus(document.ocrStatus)),
                _DocumentChip(label: document.uploadSource),
              ],
            ),
            const SizedBox(height: 12),
            Text(strings
                .uploadedAt(strings.formatDateTime(document.uploadedAt))),
            if (document.ocrProcessedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                strings.ocrProcessedAt(
                  strings.formatDateTime(document.ocrProcessedAt!),
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(strings.hashLabel(document.hash)),
            if (document.hasOcrText) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F2EA),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.ocrTextPreviewTitle,
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(document.ocrPreview),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.tonalIcon(
                  onPressed: document.isPdf ? onOpen : null,
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: Text(
                    document.isPdf
                        ? strings.openPdfAction
                        : strings.pdfOnlyLabel,
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
      ),
    );
  }
}

class _DocumentChip extends StatelessWidget {
  const _DocumentChip({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E7DA),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label),
    );
  }
}
