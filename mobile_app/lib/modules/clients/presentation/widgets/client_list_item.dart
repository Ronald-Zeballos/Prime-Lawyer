import 'package:flutter/material.dart';

import '../../domain/entities/client.dart';

class ClientListItem extends StatelessWidget {
  const ClientListItem({
    super.key,
    required this.client,
  });

  final Client client;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              client.fullName,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text('Document: ${client.documentNumber}'),
            if (client.email != null && client.email!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Email: ${client.email}'),
            ],
            if (client.phone != null && client.phone!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Phone: ${client.phone}'),
            ],
            if (client.address != null && client.address!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Address: ${client.address}'),
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
    );
  }
}
