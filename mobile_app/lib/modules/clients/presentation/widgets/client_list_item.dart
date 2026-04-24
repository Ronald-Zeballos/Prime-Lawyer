import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../shared/localization/app_strings_context.dart';
import '../../../../shared/widgets/prime_status_chip.dart';
import '../../../../shared/widgets/prime_surface_card.dart';
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
    final initials = '${client.firstName.isNotEmpty ? client.firstName[0] : ''}'
            '${client.lastName.isNotEmpty ? client.lastName[0] : ''}'
        .toUpperCase();

    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      onTap: onTap,
      child: PrimeSurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.softBeige,
                  foregroundColor: AppTheme.primaryNavy,
                  child: Text(
                    initials.isEmpty ? 'PL' : initials,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client.fullName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        client.documentNumber,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.manage_accounts_outlined),
                  label: Text(strings.manageClientAction),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                PrimeStatusChip.accent(
                  strings.caseFilesCount(linkedCaseFilesCount),
                ),
                PrimeStatusChip(
                  label: activeCaseFilesCount > 0
                      ? strings.activeCaseFilesSummary(activeCaseFilesCount)
                      : (strings.isSpanish
                          ? 'Sin casos abiertos'
                          : 'No open cases'),
                  palette: activeCaseFilesCount > 0
                      ? PrimeChipStyles.caseStatus('OPEN')
                      : PrimeChipStyles.neutral,
                ),
              ],
            ),
            if ((client.email ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              _DetailRow(
                icon: Icons.alternate_email_rounded,
                value: client.email!,
              ),
            ],
            if ((client.phone ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              _DetailRow(
                icon: Icons.phone_outlined,
                value: client.phone!,
              ),
            ],
            if ((client.address ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              _DetailRow(
                icon: Icons.location_on_outlined,
                value: client.address!,
              ),
            ],
            if ((client.notes ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.appBackground,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.softBorder),
                ),
                child: Text(
                  client.notes!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.value,
  });

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: AppTheme.textSecondary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
