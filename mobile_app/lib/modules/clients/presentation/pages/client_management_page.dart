import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../shared/localization/app_strings.dart';
import '../../../../shared/localization/app_strings_context.dart';
import '../../../../shared/widgets/prime_brand_app_bar.dart';
import '../../../../shared/widgets/prime_page_scaffold.dart';
import '../../../case_files/domain/entities/case_file.dart';
import '../controllers/clients_controller.dart';
import 'client_form_page.dart';

class ClientManagementPage extends StatelessWidget {
  const ClientManagementPage({
    super.key,
    required this.clientId,
  });

  final String clientId;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ClientsController>();
    final client = controller.getClientById(clientId);
    final strings = context.strings;

    if (client == null) {
      return PrimePageScaffold(
        appBar: PrimeBrandAppBar(
          title: strings.manageClientTitle,
          leadingIcon: Icons.arrow_back_rounded,
          leadingTooltip: strings.isSpanish ? 'Volver' : 'Back',
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              strings.clientUnavailable,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final relatedCaseFiles = controller.linkedCaseFilesForClient(client.id);
    final activeCaseFilesCount =
        controller.activeLinkedCaseFilesCount(client.id);
    final hasLinkedCaseFiles = relatedCaseFiles.isNotEmpty;
    final isDeleting = controller.isDeletingClient(client.id);

    return PrimePageScaffold(
      appBar: PrimeBrandAppBar(
        title: strings.manageClientTitle,
        leadingIcon: Icons.arrow_back_rounded,
        leadingTooltip: strings.isSpanish ? 'Volver' : 'Back',
        actions: [
          PrimeHeaderIconButton(
            icon: Icons.refresh_rounded,
            tooltip: strings.refreshClients,
            onPressed: controller.isLoading ? null : controller.refresh,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.fullName,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoChip(
                          label:
                              strings.caseFilesCount(relatedCaseFiles.length),
                        ),
                        _InfoChip(
                          label: strings.activeCaseFilesSummary(
                            activeCaseFilesCount,
                          ),
                        ),
                        _InfoChip(label: client.documentNumber),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _DetailLine(
                      label: strings.documentNumberLabel,
                      value: client.documentNumber,
                    ),
                    if ((client.phone ?? '').isNotEmpty)
                      _DetailLine(
                        label: strings.phoneLabel,
                        value: client.phone!,
                      ),
                    if ((client.email ?? '').isNotEmpty)
                      _DetailLine(
                        label: strings.emailLabel,
                        value: client.email!,
                      ),
                    if ((client.address ?? '').isNotEmpty)
                      _DetailLine(
                        label: strings.addressLabel,
                        value: client.address!,
                      ),
                    if ((client.notes ?? '').isNotEmpty)
                      _DetailLine(
                        label: strings.notesLabel,
                        value: client.notes!,
                      ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        FilledButton.icon(
                          onPressed: controller.isSubmitting
                              ? null
                              : () => _openEditClientPage(
                                    context,
                                    clientId: client.id,
                                  ),
                          icon: const Icon(Icons.edit_outlined),
                          label: Text(strings.editClientAction),
                        ),
                        OutlinedButton.icon(
                          onPressed: controller.isSubmitting || isDeleting
                              ? null
                              : hasLinkedCaseFiles
                                  ? () => _showDeleteBlockedNotice(
                                        context,
                                        strings,
                                      )
                                  : () => _confirmDelete(
                                        context,
                                        strings: strings,
                                        clientId: client.id,
                                        clientName: client.fullName,
                                      ),
                          icon: isDeleting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.delete_outline_rounded),
                          label: Text(strings.deleteClientAction),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (hasLinkedCaseFiles) ...[
              const SizedBox(height: 16),
              Card(
                color: AppTheme.warningSoft,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.deleteClientBlockedTitle,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        strings.deleteClientBlockedMessage,
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.linkedCaseFilesTitle,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(strings.linkedCaseFilesDescription),
                    const SizedBox(height: 16),
                    if (relatedCaseFiles.isEmpty)
                      _EmptyLinkedCaseFilesCard(
                        title: strings.noLinkedCaseFilesTitle,
                        description: strings.noLinkedCaseFilesDescription,
                      )
                    else
                      Column(
                        children: [
                          for (final caseFile in relatedCaseFiles)
                            _LinkedCaseFileCard(
                              caseFile: caseFile,
                              onOpen: () async {
                                await Navigator.of(context).pushNamed(
                                  AppRoutes.caseFileDetail,
                                  arguments: caseFile.id,
                                );

                                if (!context.mounted) {
                                  return;
                                }

                                await controller.refresh();
                              },
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openEditClientPage(
    BuildContext context, {
    required String clientId,
  }) async {
    final controller = context.read<ClientsController>();
    final client = controller.getClientById(clientId);

    if (client == null) {
      return;
    }

    controller.clearError();

    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => ChangeNotifierProvider<ClientsController>.value(
          value: controller,
          child: ClientFormPage.edit(clientId: client.id),
        ),
      ),
    );

    if (!context.mounted || updated != true) {
      return;
    }

    await controller.refresh();
  }

  Future<void> _confirmDelete(
    BuildContext context, {
    required AppStrings strings,
    required String clientId,
    required String clientName,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(strings.deleteClientConfirmationTitle),
          content: Text(strings.deleteClientConfirmationMessage(clientName)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(strings.cancelAction),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(strings.deleteClientConfirmAction),
            ),
          ],
        );
      },
    );

    if (!context.mounted || confirmed != true) {
      return;
    }

    final controller = context.read<ClientsController>();
    final success = await controller.deleteClient(clientId);

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? strings.clientDeletedSuccess
              : controller.errorMessage ?? strings.deleteClientFailed,
        ),
      ),
    );

    if (success) {
      Navigator.of(context).pop(true);
    }
  }

  void _showDeleteBlockedNotice(
    BuildContext context,
    AppStrings strings,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(strings.deleteClientBlockedMessage),
      ),
    );
  }
}

class _LinkedCaseFileCard extends StatelessWidget {
  const _LinkedCaseFileCard({
    required this.caseFile,
    required this.onOpen,
  });

  final CaseFile caseFile;
  final Future<void> Function() onOpen;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F2EA),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    caseFile.internalCode,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                _InfoChip(label: strings.caseStatus(caseFile.status)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              caseFile.title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),
            Text(caseFile.processType),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onOpen,
              icon: const Icon(Icons.open_in_new_rounded),
              label: Text(strings.openLinkedCaseFileAction),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyLinkedCaseFilesCard extends StatelessWidget {
  const _EmptyLinkedCaseFilesCard({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2EA),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(description),
        ],
      ),
    );
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
        color: const Color(0xFFF2E4D2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label),
    );
  }
}
