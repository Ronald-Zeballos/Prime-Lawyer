import 'package:flutter/material.dart';

import '../../domain/entities/document.dart';

class DocumentListItem extends StatelessWidget {
  const DocumentListItem({
    super.key,
    required this.document,
  });

  final Document document;

  @override
  Widget build(BuildContext context) {
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
                _DocumentChip(label: document.ocrStatus),
                _DocumentChip(label: document.uploadSource),
              ],
            ),
            const SizedBox(height: 12),
            Text('Uploaded at: ${_formatDateTime(document.uploadedAt)}'),
            const SizedBox(height: 4),
            Text('Hash: ${document.hash}'),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');

    return '${value.year}-$month-$day $hour:$minute';
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
        color: const Color(0xFFE9EEE7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label),
    );
  }
}
