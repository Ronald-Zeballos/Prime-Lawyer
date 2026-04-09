import 'package:flutter/material.dart';

import '../../../document_capture/domain/entities/captured_document.dart';

class RegisterDocumentSheet extends StatelessWidget {
  const RegisterDocumentSheet({
    super.key,
    required this.selectedDocument,
    required this.isSubmitting,
    required this.onPickDocument,
    required this.onSubmit,
    required this.onClearSelection,
    this.errorMessage,
  });

  final CapturedDocument? selectedDocument;
  final bool isSubmitting;
  final Future<void> Function() onPickDocument;
  final Future<bool> Function() onSubmit;
  final VoidCallback onClearSelection;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Register document',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: isSubmitting ? null : onPickDocument,
              icon: const Icon(Icons.attach_file_rounded),
              label: Text(
                selectedDocument == null ? 'Choose file' : 'Change file',
              ),
            ),
            if (selectedDocument != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E1D7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedDocument!.fileName,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text('Size: ${selectedDocument!.bytes.length} bytes'),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: isSubmitting ? null : onClearSelection,
                      child: const Text('Remove selection'),
                    ),
                  ],
                ),
              ),
            ],
            if (errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBE7E5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final wasCreated = await onSubmit();

                      if (!context.mounted || !wasCreated) {
                        return;
                      }

                      Navigator.of(context).pop();
                    },
              child: Text(
                isSubmitting ? 'Uploading...' : 'Upload document',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
