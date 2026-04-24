import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../shared/localization/app_strings_context.dart';
import '../../../../shared/widgets/prime_brand_app_bar.dart';
import '../../../../shared/widgets/prime_bottom_nav.dart';
import '../../../../shared/widgets/prime_empty_state.dart';
import '../../../../shared/widgets/prime_page_scaffold.dart';
import '../../../../shared/widgets/prime_search_field.dart';
import '../../../../shared/widgets/prime_surface_card.dart';
import '../../../case_files/domain/usecases/get_case_files_use_case.dart';
import '../../domain/entities/client.dart';
import '../../domain/usecases/create_client_use_case.dart';
import '../../domain/usecases/delete_client_use_case.dart';
import '../../domain/usecases/get_clients_use_case.dart';
import '../../domain/usecases/update_client_use_case.dart';
import '../controllers/clients_controller.dart';
import '../widgets/client_list_item.dart';
import 'client_form_page.dart';
import 'client_management_page.dart';

class ClientsPage extends StatelessWidget {
  const ClientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ClientsController>(
      create: (context) => ClientsController(
        getClientsUseCase: context.read<GetClientsUseCase>(),
        createClientUseCase: context.read<CreateClientUseCase>(),
        updateClientUseCase: context.read<UpdateClientUseCase>(),
        deleteClientUseCase: context.read<DeleteClientUseCase>(),
        getCaseFilesUseCase: context.read<GetCaseFilesUseCase>(),
      )..loadClients(),
      child: const _ClientsView(),
    );
  }
}

class _ClientsView extends StatefulWidget {
  const _ClientsView();

  @override
  State<_ClientsView> createState() => _ClientsViewState();
}

class _ClientsViewState extends State<_ClientsView> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  bool _isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ClientsController>();
    final strings = context.strings;
    final filteredClients = _applyLocalSearch(controller.clients);

    return PrimePageScaffold(
      currentTab: PrimeRootTab.clients,
      appBar: PrimeBrandAppBar(
        title: strings.clientsTitle,
        leadingIcon: Icons.arrow_back_rounded,
        leadingTooltip:
            context.strings.isSpanish ? 'Volver a inicio' : 'Back home',
        onLeadingPressed: () {
          PrimeBottomNav.openTab(context, PrimeRootTab.home);
        },
        actions: [
          PrimeHeaderIconButton(
            icon: _isSearchVisible ? Icons.close_rounded : Icons.search_rounded,
            tooltip: context.strings.isSpanish
                ? 'Buscar clientes'
                : 'Search clients',
            isSelected: _isSearchVisible,
            onPressed: _toggleSearch,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.isSubmitting
            ? null
            : () => _openCreateClientPage(context),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: Text(strings.newClient),
      ),
      body: Builder(
        builder: (context) {
          if (controller.isLoading && !controller.hasClients) {
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
                136,
              ),
              children: [
                PrimeSurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.isSpanish
                            ? 'Directorio de clientes'
                            : 'Client directory',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        strings.isSpanish
                            ? 'Gestiona personas y firmas bajo el sistema visual principal de Prime Lawyer.'
                            : 'Manage people and firms inside the shared Prime Lawyer system.',
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
                                Icons.groups_2_rounded,
                                color: AppTheme.accentGold,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${controller.clients.length}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    strings.clientsMetricLabel,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isSearchVisible) ...[
                  const SizedBox(height: 16),
                  PrimeSearchField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    hintText: strings.isSpanish
                        ? 'Buscar por nombre, documento o correo'
                        : 'Search by name, document or email',
                    onChanged: (_) => setState(() {}),
                    onClear: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  ),
                ],
                if (controller.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  _ClientsErrorBanner(message: controller.errorMessage!),
                ],
                const SizedBox(height: AppTheme.sectionSpacing),
                if (!controller.hasClients)
                  PrimeSurfaceCard(
                    child: PrimeEmptyState(
                      icon: Icons.people_alt_outlined,
                      title: strings.noClientsListTitle,
                      description: strings.noClientsListDescription,
                    ),
                  )
                else if (filteredClients.isEmpty)
                  PrimeSurfaceCard(
                    child: PrimeEmptyState(
                      icon: Icons.search_off_rounded,
                      title: strings.isSpanish
                          ? 'No encontramos resultados'
                          : 'No matching clients',
                      description: strings.isSpanish
                          ? 'Prueba otra búsqueda o limpia el filtro.'
                          : 'Try another search or clear the filter.',
                    ),
                  )
                else
                  for (final client in filteredClients) ...[
                    ClientListItem(
                      client: client,
                      linkedCaseFilesCount:
                          controller.linkedCaseFilesCount(client.id),
                      activeCaseFilesCount:
                          controller.activeLinkedCaseFilesCount(client.id),
                      onTap: () => _openClientManagement(context, client.id),
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

  List<Client> _applyLocalSearch(List<Client> clients) {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      return clients;
    }

    return clients.where((client) {
      return client.fullName.toLowerCase().contains(query) ||
          client.documentNumber.toLowerCase().contains(query) ||
          (client.email ?? '').toLowerCase().contains(query) ||
          (client.phone ?? '').toLowerCase().contains(query);
    }).toList(growable: false);
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;

      if (!_isSearchVisible) {
        _searchController.clear();
      }
    });

    if (_isSearchVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _searchFocusNode.requestFocus();
        }
      });
    } else {
      _searchFocusNode.unfocus();
    }
  }

  Future<void> _openCreateClientPage(BuildContext context) async {
    final controller = context.read<ClientsController>();
    controller.clearError();

    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => ChangeNotifierProvider<ClientsController>.value(
          value: controller,
          child: const ClientFormPage.create(),
        ),
      ),
    );

    if (!context.mounted || created != true) {
      return;
    }

    await controller.refresh();
  }

  Future<void> _openClientManagement(
      BuildContext context, String clientId) async {
    final controller = context.read<ClientsController>();

    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        settings: const RouteSettings(name: AppRoutes.clients),
        builder: (_) => ChangeNotifierProvider<ClientsController>.value(
          value: controller,
          child: ClientManagementPage(clientId: clientId),
        ),
      ),
    );

    if (!context.mounted || changed != true) {
      return;
    }

    await controller.refresh();
  }
}

class _ClientsErrorBanner extends StatelessWidget {
  const _ClientsErrorBanner({
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
