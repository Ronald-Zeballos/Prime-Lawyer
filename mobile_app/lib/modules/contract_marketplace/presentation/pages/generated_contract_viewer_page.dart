import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:provider/provider.dart';

import '../../../../shared/localization/app_strings_context.dart';
import '../../domain/entities/generated_contract.dart';
import '../../domain/usecases/get_generated_contract_pdf_use_case.dart';
import '../controllers/generated_contract_viewer_controller.dart';

class GeneratedContractViewerPage extends StatelessWidget {
  const GeneratedContractViewerPage({
    super.key,
    required this.contract,
  });

  final GeneratedContract contract;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GeneratedContractViewerController>(
      create: (context) => GeneratedContractViewerController(
        contract: contract,
        getGeneratedContractPdfUseCase:
            context.read<GetGeneratedContractPdfUseCase>(),
      )..load(),
      child: _GeneratedContractViewerView(contract: contract),
    );
  }
}

class _GeneratedContractViewerView extends StatelessWidget {
  const _GeneratedContractViewerView({
    required this.contract,
  });

  final GeneratedContract contract;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GeneratedContractViewerController>();
    final strings = context.strings;

    return Scaffold(
      appBar: AppBar(
        title: Text(contract.documentTitle),
        actions: [
          IconButton(
            onPressed: () => _showContractSummary(context),
            tooltip: strings.contractSummarySectionTitle,
            icon: const Icon(Icons.info_outline_rounded),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  controller.errorMessage!,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (controller.localFilePath == null) {
            return Center(
              child: Text(strings.contractPdfUnavailable),
            );
          }

          return PDFView(
            filePath: controller.localFilePath!,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: true,
            pageFling: true,
          );
        },
      ),
    );
  }

  Future<void> _showContractSummary(BuildContext context) {
    final strings = context.strings;

    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            children: [
              Text(
                contract.documentTitle,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(contract.summary),
              const SizedBox(height: 18),
              Text(
                strings.contractSummarySectionTitle,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              for (final value in contract.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SummaryLine(
                    label: value.label,
                    value: value.value,
                  ),
                ),
              if (contract.signatureLines.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  strings.contractSignaturesSectionTitle,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                for (final signatureLine in contract.signatureLines)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _SummaryLine(
                      label: signatureLine.label,
                      value: signatureLine.signerName,
                    ),
                  ),
              ],
              if (contract.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  strings.contractNotesSectionTitle,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                for (final note in contract.notes)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('• $note'),
                  ),
              ],
            ],
          ),
        );
      },
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
