import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../shared/localization/app_strings_context.dart';
import '../../../case_files/domain/usecases/get_case_files_use_case.dart';
import '../../domain/usecases/create_client_use_case.dart';
import '../../domain/usecases/delete_client_use_case.dart';
import '../../domain/usecases/get_clients_use_case.dart';
import '../../domain/usecases/update_client_use_case.dart';
import '../controllers/clients_controller.dart';
import 'client_form_page.dart';
import 'client_management_page.dart';
import '../widgets/client_list_item.dart';

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

class _ClientsView extends StatelessWidget {
  const _ClientsView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ClientsController>();
    final strings = context.strings;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.clientsTitle),
        actions: [
          IconButton(
            onPressed: controller.isLoading ? null : controller.refresh,
            tooltip: strings.refreshClients,
            icon: const Icon(Icons.refresh_rounded),
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
      body: Column(
        children: [
          if (controller.errorMessage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
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
            ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (controller.isLoading && !controller.hasClients) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!controller.hasClients) {
                  return RefreshIndicator(
                    onRefresh: controller.refresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      children: [
                        const SizedBox(height: 80),
                        Icon(
                          Icons.people_alt_outlined,
                          size: 56,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          strings.noClientsListTitle,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          strings.noClientsListDescription,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.refresh,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    itemCount: controller.clients.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final client = controller.clients[index];

                      return ClientListItem(
                        client: client,
                        linkedCaseFilesCount:
                            controller.linkedCaseFilesCount(client.id),
                        activeCaseFilesCount:
                            controller.activeLinkedCaseFilesCount(client.id),
                        onTap: () => _openClientManagement(context, client.id),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
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

  Future<void> _openClientManagement(BuildContext context, String clientId) async {
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
