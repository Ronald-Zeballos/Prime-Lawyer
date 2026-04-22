import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/localization/app_strings_context.dart';
import '../../domain/entities/contract_template.dart';
import '../../domain/entities/generated_contract.dart';
import '../../domain/usecases/get_active_contract_templates_use_case.dart';
import '../../domain/usecases/get_generated_contracts_use_case.dart';
import '../controllers/contract_marketplace_controller.dart';
import 'contract_template_form_page.dart';
import 'generated_contract_viewer_page.dart';

class ContractMarketplacePage extends StatelessWidget {
  const ContractMarketplacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ContractMarketplaceController>(
      create: (context) => ContractMarketplaceController(
        getActiveContractTemplatesUseCase:
            context.read<GetActiveContractTemplatesUseCase>(),
        getGeneratedContractsUseCase:
            context.read<GetGeneratedContractsUseCase>(),
      )..loadInitialData(),
      child: const _ContractMarketplaceView(),
    );
  }
}

class _ContractMarketplaceView extends StatelessWidget {
  const _ContractMarketplaceView();

  static const List<String> _upcomingTemplates = <String>[
    'Contrato de prestación de servicios',
    'Contrato laboral base',
    'Poder notarial simple',
  ];

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ContractMarketplaceController>();
    final strings = context.strings;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.contractMarketplaceTitle),
        actions: [
          IconButton(
            onPressed: controller.isLoading ? null : controller.refresh,
            tooltip: strings.refreshContractMarketplace,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (controller.isLoading &&
              !controller.hasTemplates &&
              !controller.hasGeneratedContracts) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.refresh,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F2EA),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.contractMarketplaceHeroTitle,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(strings.contractMarketplaceHeroDescription),
                    ],
                  ),
                ),
                if (controller.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBE7E5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      controller.errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Text(
                  strings.contractTemplatesSectionTitle,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                if (!controller.hasTemplates)
                  _EmptySectionCard(
                    title: strings.contractTemplatesEmptyTitle,
                    description: strings.contractTemplatesEmptyDescription,
                    icon: Icons.description_outlined,
                  )
                else
                  for (final template in controller.templates) ...[
                    _TemplateCard(
                      template: template,
                      onOpen: () => _openTemplate(context, template),
                    ),
                    const SizedBox(height: 12),
                  ],
                const SizedBox(height: 12),
                Text(
                  strings.upcomingTemplatesTitle,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(strings.upcomingTemplatesDescription),
                const SizedBox(height: 12),
                for (final templateName in _upcomingTemplates) ...[
                  _UpcomingTemplateCard(title: templateName),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 8),
                Text(
                  strings.generatedContractsSectionTitle,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                if (!controller.hasGeneratedContracts)
                  _EmptySectionCard(
                    title: strings.noGeneratedContractsTitle,
                    description: strings.noGeneratedContractsDescription,
                    icon: Icons.picture_as_pdf_outlined,
                  )
                else
                  for (final contract in controller.generatedContracts) ...[
                    _GeneratedContractCard(
                      contract: contract,
                      onOpen: () => _openContract(context, contract),
                    ),
                    const SizedBox(height: 12),
                  ],
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openTemplate(
    BuildContext context,
    ContractTemplate template,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ContractTemplateFormPage(
          templateSlug: template.slug,
        ),
      ),
    );

    if (!context.mounted) {
      return;
    }

    await context.read<ContractMarketplaceController>().refresh();
  }

  Future<void> _openContract(
    BuildContext context,
    GeneratedContract contract,
  ) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GeneratedContractViewerPage(contract: contract),
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.template,
    required this.onOpen,
  });

  final ContractTemplate template;
  final Future<void> Function() onOpen;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              template.name,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            if ((template.description ?? '').trim().isNotEmpty)
              Text(template.description!),
            if ((template.description ?? '').trim().isNotEmpty)
              const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Chip(
                  label: strings.contractFieldCountLabel(template.fieldCount),
                ),
                _Chip(
                  label: _formatPrice(
                    template.priceCents,
                    template.currency,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () async {
                await onOpen();
              },
              icon: const Icon(Icons.edit_note_rounded),
              label: Text(strings.openContractTemplateAction),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(int priceCents, String currency) {
    final majorUnits = (priceCents / 100).toStringAsFixed(2);

    return '$currency $majorUnits';
  }
}

class _GeneratedContractCard extends StatelessWidget {
  const _GeneratedContractCard({
    required this.contract,
    required this.onOpen,
  });

  final GeneratedContract contract;
  final Future<void> Function() onOpen;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contract.documentTitle,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(contract.summary),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Chip(label: contract.templateName),
                _Chip(
                  label: strings.contractGeneratedOn(
                    strings.formatShortDate(contract.createdAt),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: () async {
                await onOpen();
              },
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: Text(strings.openGeneratedContractAction),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpcomingTemplateCard extends StatelessWidget {
  const _UpcomingTemplateCard({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(strings.contractTemplatePendingUploadDescription),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _Chip(label: strings.comingSoonLabel),
          ],
        ),
      ),
    );
  }
}

class _EmptySectionCard extends StatelessWidget {
  const _EmptySectionCard({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(icon, size: 36),
            const SizedBox(height: 10),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
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
