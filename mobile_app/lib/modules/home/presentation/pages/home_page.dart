import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../shared/providers/session_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final sessionProvider = context.watch<SessionProvider>();
    final currentUser = sessionProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prime Lawyer'),
        actions: [
          IconButton(
            onPressed: () async {
              await context.read<SessionProvider>().clearSession();
            },
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentUser == null ? 'Welcome back' : 'Welcome, ${currentUser.firstName}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  currentUser == null
                      ? 'The session is active and ready for the next MVP modules.'
                      : 'Signed in as ${currentUser.fullName} (${currentUser.role}). The next phases will plug in clients, case files and documents.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onPrimary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.clients);
            },
            icon: const Icon(Icons.people_alt_outlined),
            label: const Text('Open clients module'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.caseFiles);
            },
            icon: const Icon(Icons.folder_open_outlined),
            label: const Text('Open case files module'),
          ),
          const SizedBox(height: 20),
          Text(
            'Upcoming MVP modules',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          const _ModuleStatusCard(
            icon: Icons.lock_outline_rounded,
            title: 'Authentication',
            description: 'Login with JWT is already connected for the mobile MVP.',
          ),
          const SizedBox(height: 12),
          const _ModuleStatusCard(
            icon: Icons.people_alt_outlined,
            title: 'Clients',
            description: 'Client list and create form are already connected in this phase.',
          ),
          const SizedBox(height: 12),
          const _ModuleStatusCard(
            icon: Icons.folder_open_outlined,
            title: 'Case files',
            description: 'Case file list, detail and create form are already connected in this phase.',
          ),
          const SizedBox(height: 12),
          const _ModuleStatusCard(
            icon: Icons.description_outlined,
            title: 'Documents',
            description: 'Document listing and real upload are already connected in this phase.',
          ),
        ],
      ),
    );
  }
}

class _ModuleStatusCard extends StatelessWidget {
  const _ModuleStatusCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(width: 12),
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
                  Text(description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
