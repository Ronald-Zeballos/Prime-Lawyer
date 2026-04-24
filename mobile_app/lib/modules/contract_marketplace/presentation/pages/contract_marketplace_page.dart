import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../shared/localization/app_strings_context.dart';
import '../../../../shared/widgets/prime_brand_app_bar.dart';
import '../../../../shared/widgets/prime_bottom_nav.dart';
import '../../../../shared/widgets/prime_empty_state.dart';
import '../../../../shared/widgets/prime_page_scaffold.dart';
import '../../../../shared/widgets/prime_status_chip.dart';
import '../../../../shared/widgets/prime_surface_card.dart';
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

    return PrimePageScaffold(
      currentTab: PrimeRootTab.marketplace,
      appBar: PrimeBrandAppBar(
        title: strings.contractMarketplaceTitle,
        leadingIcon: Icons.arrow_back_rounded,
        leadingTooltip: strings.isSpanish ? 'Volver a inicio' : 'Back home',
        onLeadingPressed: () {
          PrimeBottomNav.openTab(context, PrimeRootTab.home);
        },
        actions: [
          PrimeHeaderIconButton(
            icon: Icons.refresh_rounded,
            tooltip: strings.refreshContractMarketplace,
            onPressed: controller.isLoading ? null : controller.refresh,
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
              padding: const EdgeInsets.fromLTRB(
                AppTheme.pagePadding,
                8,
                AppTheme.pagePadding,
                132,
              ),
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppTheme.primaryNavy,
                        AppTheme.secondaryNavy,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(34),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PrimeStatusChip.accent(
                        strings.isSpanish
                            ? 'Prime templates'
                            : 'Prime templates',
                      ),
                      const SizedBox(height: 16),
                      Text(
                        strings.contractMarketplaceHeroTitle,
                        style:
                            Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: AppTheme.surface,
                                ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        strings.contractMarketplaceHeroDescription,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.surface.withValues(alpha: 0.92),
                            ),
                      ),
                    ],
                  ),
                ),
                if (controller.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  _MarketplaceErrorBanner(message: controller.errorMessage!),
                ],
                const SizedBox(height: AppTheme.sectionSpacing),
                _SectionHeader(
                  title: strings.contractTemplatesSectionTitle,
                  subtitle: strings.isSpanish
                      ? 'Plantillas activas listas para abrir formulario.'
                      : 'Active templates ready to open their forms.',
                ),
                const SizedBox(height: 14),
                if (!controller.hasTemplates)
                  PrimeSurfaceCard(
                    child: PrimeEmptyState(
                      icon: Icons.description_outlined,
                      title: strings.contractTemplatesEmptyTitle,
                      description: strings.contractTemplatesEmptyDescription,
                    ),
                  )
                else
                  for (final template in controller.templates) ...[
                    _TemplateCard(
                      template: template,
                      onOpen: () => _openTemplate(context, template),
                    ),
                    const SizedBox(height: 14),
                  ],
                const SizedBox(height: AppTheme.sectionSpacing),
                _SectionHeader(
                  title: strings.upcomingTemplatesTitle,
                  subtitle: strings.upcomingTemplatesDescription,
                ),
                const SizedBox(height: 14),
                for (final templateName in _upcomingTemplates) ...[
                  _UpcomingTemplateCard(title: templateName),
                  const SizedBox(height: 14),
                ],
                const SizedBox(height: AppTheme.sectionSpacing),
                _SectionHeader(
                  title: strings.generatedContractsSectionTitle,
                  subtitle: strings.isSpanish
                      ? 'Documentos ya generados para seguir el flujo legal real.'
                      : 'Generated documents ready to continue the real legal flow.',
                ),
                const SizedBox(height: 14),
                if (!controller.hasGeneratedContracts)
                  PrimeSurfaceCard(
                    child: PrimeEmptyState(
                      icon: Icons.picture_as_pdf_outlined,
                      title: strings.noGeneratedContractsTitle,
                      description: strings.noGeneratedContractsDescription,
                    ),
                  )
                else
                  for (final contract in controller.generatedContracts) ...[
                    _GeneratedContractCard(
                      contract: contract,
                      onOpen: () => _openContract(context, contract),
                    ),
                    const SizedBox(height: 14),
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

    return PrimeSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            template.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 10),
          if ((template.description ?? '').trim().isNotEmpty)
            Text(
              template.description!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          if ((template.description ?? '').trim().isNotEmpty)
            const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              PrimeStatusChip.accent(
                strings.contractFieldCountLabel(template.fieldCount),
              ),
              PrimeStatusChip.accent(
                _formatPrice(template.priceCents, template.currency),
              ),
            ],
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () async {
              await onOpen();
            },
            icon: const Icon(Icons.edit_note_rounded),
            label: Text(strings.openContractTemplateAction),
          ),
        ],
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
    return PrimeSurfaceCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  context.strings.isSpanish
                      ? 'Este flujo queda listo para conectarse cuando el estudio jurídico comparta la plantilla final.'
                      : 'This flow is ready to connect as soon as the legal team shares the final template.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          PrimeStatusChip.neutral(
            context.strings.isSpanish ? 'Próximamente' : 'Coming soon',
          ),
        ],
      ),
    );
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
    return PrimeSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            contract.documentTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            contract.summary,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              PrimeStatusChip.accent(contract.templateName),
              PrimeStatusChip.neutral(
                _formatPrice(contract.priceCents, contract.currency),
              ),
            ],
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () async {
              await onOpen();
            },
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: Text(context.strings.isSpanish ? 'Abrir PDF' : 'Open PDF'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _MarketplaceErrorBanner extends StatelessWidget {
  const _MarketplaceErrorBanner({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.errorSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.error.withValues(alpha: 0.16)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.error,
              ),
        ),
      ),
    );
  }
}

String _formatPrice(int priceCents, String currency) {
  final normalizedPrice = (priceCents / 100).toStringAsFixed(2);

  return '$currency $normalizedPrice';
}
