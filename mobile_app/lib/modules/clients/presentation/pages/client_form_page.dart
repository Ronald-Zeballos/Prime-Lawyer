import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/localization/app_strings_context.dart';
import '../../../../shared/widgets/prime_brand_app_bar.dart';
import '../../../../shared/widgets/prime_page_scaffold.dart';
import '../../domain/repositories/client_repository.dart';
import '../controllers/clients_controller.dart';
import '../widgets/client_form_sheet.dart';

enum ClientFormMode {
  create,
  edit,
}

class ClientFormPage extends StatelessWidget {
  const ClientFormPage.create({super.key})
      : mode = ClientFormMode.create,
        clientId = null;

  const ClientFormPage.edit({
    super.key,
    required this.clientId,
  }) : mode = ClientFormMode.edit;

  final ClientFormMode mode;
  final String? clientId;

  bool get isEditing => mode == ClientFormMode.edit;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ClientsController>();
    final strings = context.strings;
    final client = isEditing && clientId != null
        ? controller.getClientById(clientId!)
        : null;

    if (isEditing && client == null) {
      return PrimePageScaffold(
        appBar: PrimeBrandAppBar(
          title: strings.editClientTitle,
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

    return PrimePageScaffold(
      appBar: PrimeBrandAppBar(
        title: isEditing ? strings.editClientTitle : strings.createClientTitle,
        leadingIcon: Icons.arrow_back_rounded,
        leadingTooltip: strings.isSpanish ? 'Volver' : 'Back',
      ),
      body: ClientFormSheet(
        showHeader: false,
        title: isEditing ? strings.editClientTitle : strings.createClientTitle,
        submitLabel: isEditing
            ? strings.saveClientChangesAction
            : strings.createClientAction,
        submittingLabel: isEditing ? strings.savingChanges : strings.creating,
        initialData: client == null
            ? null
            : ClientFormData(
                firstName: client.firstName,
                lastName: client.lastName,
                documentNumber: client.documentNumber,
                phone: client.phone,
                email: client.email,
                address: client.address,
                notes: client.notes,
              ),
        isSubmitting: controller.isSubmitting,
        errorMessage: controller.errorMessage,
        onSubmit: (input) async {
          final success = isEditing
              ? await controller.updateClient(
                  UpdateClientInput(
                    clientId: client!.id,
                    firstName: input.firstName,
                    lastName: input.lastName,
                    documentNumber: input.documentNumber,
                    phone: input.phone,
                    email: input.email,
                    address: input.address,
                    notes: input.notes,
                  ),
                )
              : await controller.createClient(
                  CreateClientInput(
                    firstName: input.firstName,
                    lastName: input.lastName,
                    documentNumber: input.documentNumber,
                    phone: input.phone,
                    email: input.email,
                    address: input.address,
                    notes: input.notes,
                  ),
                );

          if (!context.mounted || !success) {
            return success;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEditing
                    ? strings.clientUpdatedSuccess
                    : strings.clientCreatedSuccess,
              ),
            ),
          );

          return success;
        },
      ),
    );
  }
}
