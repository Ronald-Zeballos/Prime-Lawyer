import 'package:flutter/material.dart';

import '../../../../shared/localization/app_strings_context.dart';
import '../../domain/entities/client.dart';

class ClientListItem extends StatelessWidget {
  const ClientListItem({
    super.key,
    required this.client,
    required this.linkedCaseFilesCount,
    required this.activeCaseFilesCount,
    required this.onTap,
  });

  final Client client;
  final int linkedCaseFilesCount;
  final int activeCaseFilesCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      client.fullName,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.manage_accounts_outlined),
                    label: Text(strings.manageClientAction),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text('${strings.documentFieldLabel}: ${client.documentNumber}'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(label: strings.caseFilesCount(linkedCaseFilesCount)),
                  _InfoChip(
                    label: strings.activeCaseFilesSummary(activeCaseFilesCount),
                  ),
                ],
              ),
              if (client.email != null && client.email!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text('${strings.emailLabel}: ${client.email}'),
              ],
              if (client.phone != null && client.phone!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text('${strings.phoneLabel}: ${client.phone}'),
              ],
              if (client.address != null && client.address!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text('${strings.addressLabel}: ${client.address}'),
              ],
              if (client.notes != null && client.notes!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  client.notes!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
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
