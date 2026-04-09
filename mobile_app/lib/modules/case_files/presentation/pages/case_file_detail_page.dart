import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../clients/domain/usecases/get_clients_use_case.dart';
import '../../../documents/presentation/pages/documents_page.dart';
import '../../domain/usecases/get_case_file_detail_use_case.dart';
import '../controllers/case_file_detail_controller.dart';

class CaseFileDetailPage extends StatelessWidget {
  const CaseFileDetailPage({
    super.key,
    required this.caseFileId,
  });

  final String caseFileId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CaseFileDetailController>(
      create: (context) => CaseFileDetailController(
        getCaseFileDetailUseCase: context.read<GetCaseFileDetailUseCase>(),
        getClientsUseCase: context.read<GetClientsUseCase>(),
      )..load(caseFileId),
      child: const _CaseFileDetailView(),
    );
  }
}

class _CaseFileDetailView extends StatelessWidget {
  const _CaseFileDetailView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CaseFileDetailController>();
    final caseFile = controller.caseFile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Case file detail'),
      ),
      body: Builder(
        builder: (context) {
          if (controller.isLoading && caseFile == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.errorMessage != null && caseFile == null) {
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

          if (caseFile == null) {
            return const Center(
              child: Text('Case file not available.'),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        caseFile.internalCode,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(caseFile.subject),
                      const SizedBox(height: 16),
                      _DetailLine(
                        label: 'Client',
                        value: controller.clientLabel ?? caseFile.clientId,
                      ),
                      _DetailLine(
                        label: 'Process type',
                        value: caseFile.processType,
                      ),
                      _DetailLine(label: 'Status', value: caseFile.status),
                      _DetailLine(
                        label: 'Confidentiality',
                        value: caseFile.confidentialityLevel,
                      ),
                      _DetailLine(
                        label: 'Opened at',
                        value: _formatDateTime(caseFile.openedAt),
                      ),
                      _DetailLine(
                        label: 'Closed at',
                        value: caseFile.closedAt == null
                            ? 'Not closed'
                            : _formatDateTime(caseFile.closedAt!),
                      ),
                      const SizedBox(height: 10),
                      FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                            AppRoutes.documents,
                            arguments: DocumentsPageArgs(
                              caseFileId: caseFile.id,
                              caseFileTitle: caseFile.internalCode,
                            ),
                          );
                        },
                        icon: const Icon(Icons.description_outlined),
                        label: const Text('Open documents'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
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

class _DetailLine extends StatelessWidget {
  const _DetailLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
