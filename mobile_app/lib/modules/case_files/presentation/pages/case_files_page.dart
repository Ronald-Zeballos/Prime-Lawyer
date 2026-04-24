import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../shared/localization/app_strings_context.dart';
import '../../../../shared/widgets/prime_brand_app_bar.dart';
import '../../../../shared/widgets/prime_bottom_nav.dart';
import '../../../../shared/widgets/prime_empty_state.dart';
import '../../../../shared/widgets/prime_page_scaffold.dart';
import '../../../../shared/widgets/prime_status_chip.dart';
import '../../../../shared/widgets/prime_surface_card.dart';
import '../../../clients/domain/usecases/get_clients_use_case.dart';
import '../../domain/entities/case_file.dart';
import '../../domain/usecases/create_case_file_use_case.dart';
import '../../domain/usecases/get_case_files_use_case.dart';
import '../controllers/case_files_controller.dart';
import '../widgets/case_file_list_item.dart';
import '../widgets/create_case_file_sheet.dart';

class CaseFilesPage extends StatelessWidget {
  const CaseFilesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CaseFilesController>(
      create: (context) => CaseFilesController(
        getCaseFilesUseCase: context.read<GetCaseFilesUseCase>(),
        createCaseFileUseCase: context.read<CreateCaseFileUseCase>(),
        getClientsUseCase: context.read<GetClientsUseCase>(),
      )..loadInitialData(),
      child: const _CaseFilesView(),
    );
  }
}

class _CaseFilesView extends StatefulWidget {
  const _CaseFilesView();

  @override
  State<_CaseFilesView> createState() => _CaseFilesViewState();
}

class _CaseFilesViewState extends State<_CaseFilesView> {
  String? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CaseFilesController>();
    final strings = context.strings;
    final filteredCaseFiles = _applyFilters(controller.caseFiles);

    return PrimePageScaffold(
      currentTab: PrimeRootTab.caseFiles,
      appBar: PrimeBrandAppBar(
        title: strings.caseFilesTitle,
        leadingIcon: Icons.arrow_back_rounded,
        leadingTooltip: strings.isSpanish ? 'Volver a inicio' : 'Back home',
        onLeadingPressed: () {
          PrimeBottomNav.openTab(context, PrimeRootTab.home);
        },
        actions: [
          PrimeHeaderIconButton(
            icon: Icons.filter_list_rounded,
            tooltip:
                strings.isSpanish ? 'Filtrar expedientes' : 'Filter case files',
            isSelected: _statusFilter != null,
            onPressed: () => _showFilterSheet(context),
          ),
          PrimeHeaderIconButton(
            icon: Icons.refresh_rounded,
            tooltip: strings.refreshCaseFiles,
            onPressed: controller.isLoading ? null : controller.refresh,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => controller.hasClients
            ? _openCreateCaseFileSheet(context)
            : _showCreateClientRequiredMessage(context),
        icon: const Icon(Icons.create_new_folder_outlined),
        label: Text(strings.newCaseFile),
      ),
      body: Builder(
        builder: (context) {
          return RefreshIndicator(
            onRefresh: controller.refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppTheme.pagePadding,
                8,
                AppTheme.pagePadding,
                136,
              ),
              children: [
                PrimeSurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.isSpanish
                            ? 'Control de expedientes'
                            : 'Case file control',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        strings.isSpanish
                            ? 'Revisa estados, visibilidad y acceso rápido al repositorio colaborativo.'
                            : 'Review status, visibility and fast access to the collaborative repository.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppTheme.softBeige,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryNavy,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.work_rounded,
                                color: AppTheme.accentGold,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${controller.caseFiles.length}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    strings.totalCaseFilesMetricLabel,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed(AppRoutes.knowledgeRepository);
                          },
                          icon: const Icon(Icons.library_books_outlined),
                          label: Text(strings.openKnowledgeRepository),
                        ),
                      ),
                      if (controller.isLoading) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                strings.isSpanish
                                    ? 'Actualizando expedientes y clientes vinculados...'
                                    : 'Refreshing case files and linked clients...',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (_statusFilter != null) ...[
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            PrimeStatusChip.accent(
                              strings.caseStatus(_statusFilter!),
                            ),
                            const SizedBox(width: 10),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _statusFilter = null;
                                });
                              },
                              child: Text(
                                strings.isSpanish
                                    ? 'Limpiar filtro'
                                    : 'Clear filter',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                if (controller.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  _CaseFilesErrorBanner(message: controller.errorMessage!),
                ],
                const SizedBox(height: AppTheme.sectionSpacing),
                if (controller.isLoading && !controller.hasCaseFiles)
                  PrimeSurfaceCard(
                    child: PrimeEmptyState(
                      icon: Icons.folder_open_rounded,
                      title: strings.isSpanish
                          ? 'Cargando expedientes'
                          : 'Loading case files',
                      description: strings.isSpanish
                          ? 'Estamos preparando el resumen principal y el listado jurídico.'
                          : 'We are preparing the main summary and the legal file list.',
                    ),
                  )
                else if (!controller.hasCaseFiles)
                  PrimeSurfaceCard(
                    child: PrimeEmptyState(
                      icon: Icons.folder_open_outlined,
                      title: strings.noCaseFilesListTitle,
                      description: controller.hasClients
                          ? strings.noCaseFilesListWithClientsDescription
                          : strings.noCaseFilesListWithoutClientsDescription,
                    ),
                  )
                else if (filteredCaseFiles.isEmpty)
                  PrimeSurfaceCard(
                    child: PrimeEmptyState(
                      icon: Icons.filter_alt_off_rounded,
                      title: strings.isSpanish
                          ? 'No hay casos con ese filtro'
                          : 'No cases match this filter',
                      description: strings.isSpanish
                          ? 'Cambia el estado seleccionado para ver otros expedientes.'
                          : 'Change the selected status to see other case files.',
                    ),
                  )
                else
                  for (final caseFile in filteredCaseFiles) ...[
                    CaseFileListItem(
                      caseFile: caseFile,
                      onTap: () async {
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
                    const SizedBox(height: 14),
                  ],
              ],
            ),
          );
        },
      ),
    );
  }

  List<CaseFile> _applyFilters(List<CaseFile> caseFiles) {
    if (_statusFilter == null) {
      return caseFiles;
    }

    return caseFiles
        .where((caseFile) => caseFile.status == _statusFilter)
        .toList(growable: false);
  }

  Future<void> _showFilterSheet(BuildContext context) async {
    final strings = context.strings;
    final selected = await showModalBottomSheet<String?>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.isSpanish ? 'Filtrar por estado' : 'Filter by status',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 14),
                for (final option in const <String?>[
                  null,
                  'OPEN',
                  'IN_PROGRESS',
                  'CLOSED',
                  'ARCHIVED',
                ])
                  ListTile(
                    title: Text(
                      option == null
                          ? (strings.isSpanish ? 'Todos' : 'All')
                          : strings.caseStatus(option),
                    ),
                    trailing: _statusFilter == option
                        ? const Icon(Icons.check_rounded)
                        : null,
                    onTap: () => Navigator.of(context).pop(option),
                  ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _statusFilter = selected;
    });
  }

  Future<void> _openCreateCaseFileSheet(BuildContext context) {
    final controller = context.read<CaseFilesController>();
    controller.clearError();
    final strings = context.strings;

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ChangeNotifierProvider<CaseFilesController>.value(
        value: controller,
        child: Consumer<CaseFilesController>(
          builder: (context, value, _) => CreateCaseFileSheet(
            clients: value.clients,
            isSubmitting: value.isSubmitting,
            errorMessage: value.errorMessage,
            onSubmit: (input) async {
              final success = await value.createCaseFile(input);

              if (!context.mounted) {
                return success;
              }

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(strings.caseFileCreatedSuccess)),
                );
              }

              return success;
            },
          ),
        ),
      ),
    );
  }

  void _showCreateClientRequiredMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.strings.createClientBeforeCaseFile)),
    );
  }
}

class _CaseFilesErrorBanner extends StatelessWidget {
  const _CaseFilesErrorBanner({
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
