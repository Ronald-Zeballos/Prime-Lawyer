import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/usecases/create_client_use_case.dart';
import '../../domain/usecases/get_clients_use_case.dart';
import '../controllers/clients_controller.dart';
import '../widgets/client_list_item.dart';
import '../widgets/create_client_sheet.dart';

class ClientsPage extends StatelessWidget {
  const ClientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ClientsController>(
      create: (context) => ClientsController(
        getClientsUseCase: context.read<GetClientsUseCase>(),
        createClientUseCase: context.read<CreateClientUseCase>(),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
        actions: [
          IconButton(
            onPressed: controller.isLoading ? null : controller.refresh,
            tooltip: 'Refresh clients',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateClientSheet(context),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('New client'),
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
                          'No clients yet',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Create your first client to start the MVP legal flow.',
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

                      return ClientListItem(client: client);
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

  Future<void> _openCreateClientSheet(BuildContext context) {
    final controller = context.read<ClientsController>();
    controller.clearError();

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ChangeNotifierProvider<ClientsController>.value(
        value: controller,
        child: Consumer<ClientsController>(
          builder: (context, value, _) => CreateClientSheet(
            isSubmitting: value.isSubmitting,
            errorMessage: value.errorMessage,
            onSubmit: value.createClient,
          ),
        ),
      ),
    );
  }
}
