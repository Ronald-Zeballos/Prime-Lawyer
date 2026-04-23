import 'dart:io';

import 'package:flutter/material.dart';

import '../../domain/entities/document_scan_draft.dart';

class DocumentScanPageCard extends StatelessWidget {
  const DocumentScanPageCard({
    super.key,
    required this.page,
    required this.pageNumber,
    required this.canDelete,
    required this.previewUnavailableLabel,
    required this.rotateLabel,
    required this.deleteLabel,
    required this.pageLabel,
    required this.onRotate,
    required this.onDelete,
  });

  final DocumentScanDraftPage page;
  final int pageNumber;
  final bool canDelete;
  final String previewUnavailableLabel;
  final String rotateLabel;
  final String deleteLabel;
  final String pageLabel;
  final VoidCallback onRotate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: ValueKey(page.id),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$pageLabel $pageNumber',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  tooltip: rotateLabel,
                  onPressed: onRotate,
                  icon: const Icon(Icons.rotate_90_degrees_cw_rounded),
                ),
                IconButton(
                  tooltip: deleteLabel,
                  onPressed: canDelete ? onDelete : null,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
                ReorderableDragStartListener(
                  index: pageNumber - 1,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.drag_handle_rounded),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AspectRatio(
              aspectRatio: 0.75,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ColoredBox(
                  color: const Color(0xFFF2ECE3),
                  child: RotatedBox(
                    quarterTurns: page.rotationQuarterTurns,
                    child: Image.file(
                      File(page.sourceImagePath),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              previewUnavailableLabel,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
