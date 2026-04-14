import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../case_files/domain/entities/case_file.dart';
import '../../../clients/domain/entities/client.dart';
import '../../domain/usecases/get_home_dashboard_use_case.dart';
import '../controllers/home_dashboard_controller.dart';
import '../../../../shared/providers/session_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeDashboardController>(
      create: (context) => HomeDashboardController(
        getHomeDashboardUseCase: context.read<GetHomeDashboardUseCase>(),
      )..loadDashboard(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final sessionProvider = context.watch<SessionProvider>();
    final dashboardController = context.watch<HomeDashboardController>();
    final currentUser = sessionProvider.currentUser;
    final dashboard = dashboardController.dashboard;

    if (dashboardController.isLoading && dashboard == null) {
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
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
      body: RefreshIndicator(
        onRefresh: dashboardController.refresh,
        child: ListView(
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
                    currentUser == null
                        ? 'Welcome back'
                        : 'Welcome, ${currentUser.displayLabel}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentUser == null
                        ? 'The session is active and ready for the next legal actions.'
                        : 'Signed in as ${currentUser.displayLabel} (${currentUser.role}). Your dashboard is now reading live data from the MVP backend.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onPrimary,
                        ),
                  ),
                  if (dashboard != null) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _HeroPill(
                          label: '${dashboard.totalClients} clients',
                        ),
                        _HeroPill(
                          label: '${dashboard.totalCaseFiles} case files',
                        ),
                        _HeroPill(
                          label: '${dashboard.activeCaseFilesCount} active cases',
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (dashboardController.errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBE7E5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  dashboardController.errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Text(
              'Quick actions',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.clients);
              },
              icon: const Icon(Icons.people_alt_outlined),
              label: const Text('Manage clients'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.caseFiles);
              },
              icon: const Icon(Icons.folder_open_outlined),
              label: const Text('Manage case files'),
            ),
            if (dashboard != null && dashboard.recentCaseFiles.isNotEmpty) ...[
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.caseFileDetail,
                    arguments: dashboard.recentCaseFiles.first.id,
                  );
                },
                icon: const Icon(Icons.playlist_play_rounded),
                label: Text(
                  'Resume ${dashboard.recentCaseFiles.first.internalCode}',
                ),
              ),
            ],
            const SizedBox(height: 20),
            Text(
              'Current snapshot',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DashboardMetricCard(
                    icon: Icons.people_alt_outlined,
                    label: 'Clients',
                    value: '${dashboard?.totalClients ?? 0}',
                    caption: 'Registered people and firms',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DashboardMetricCard(
                    icon: Icons.folder_open_outlined,
                    label: 'Active cases',
                    value: '${dashboard?.activeCaseFilesCount ?? 0}',
                    caption: 'Open or in progress',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _SectionCard(
              title: 'Recent clients',
              child: dashboard == null || !dashboard.hasRecentClients
                  ? const _EmptySectionMessage(
                      icon: Icons.person_add_alt_1_rounded,
                      title: 'No clients yet',
                      description:
                          'Create your first client and it will appear here.',
                    )
                  : Column(
                      children: [
                        for (final client in dashboard.recentClients)
                          _RecentClientTile(client: client),
                      ],
                    ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Recent case files',
              child: dashboard == null || !dashboard.hasRecentCaseFiles
                  ? const _EmptySectionMessage(
                      icon: Icons.create_new_folder_outlined,
                      title: 'No case files yet',
                      description:
                          'Create a case file and the dashboard will surface it here.',
                    )
                  : Column(
                      children: [
                        for (final caseFile in dashboard.recentCaseFiles)
                          _RecentCaseFileTile(
                            caseFile: caseFile,
                            onOpen: () {
                              Navigator.of(context).pushNamed(
                                AppRoutes.caseFileDetail,
                                arguments: caseFile.id,
                              );
                            },
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _DashboardMetricCard extends StatelessWidget {
  const _DashboardMetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.caption,
  });

  final IconData icon;
  final String label;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(caption),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _EmptySectionMessage extends StatelessWidget {
  const _EmptySectionMessage({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2EA),
        borderRadius: BorderRadius.circular(18),
      ),
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
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(description),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentClientTile extends StatelessWidget {
  const _RecentClientTile({
    required this.client,
  });

  final Client client;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F2EA),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                client.firstName.isEmpty
                    ? '?'
                    : client.firstName[0].toUpperCase(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.fullName,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text('Document: ${client.documentNumber}'),
                  const SizedBox(height: 4),
                  Text('Created ${_formatDashboardDate(client.createdAt)}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentCaseFileTile extends StatelessWidget {
  const _RecentCaseFileTile({
    required this.caseFile,
    required this.onOpen,
  });

  final CaseFile caseFile;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F2EA),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    caseFile.internalCode,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                _CaseStatusChip(status: caseFile.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              caseFile.title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if ((caseFile.description ?? '').isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                caseFile.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Text('Opened ${_formatDashboardDate(caseFile.openedAt)}'),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: onOpen,
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Open case file'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaseStatusChip extends StatelessWidget {
  const _CaseStatusChip({
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    final palette = _statusPalette(status, Theme.of(context).colorScheme);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(
          color: palette.foreground,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

({Color background, Color foreground}) _statusPalette(
  String status,
  ColorScheme colorScheme,
) {
  switch (status) {
    case 'OPEN':
      return (
        background: const Color(0xFFE3F2E7),
        foreground: const Color(0xFF1F6A3A),
      );
    case 'IN_PROGRESS':
      return (
        background: const Color(0xFFFFF1D6),
        foreground: const Color(0xFF8B5A00),
      );
    case 'CLOSED':
      return (
        background: const Color(0xFFE6ECF5),
        foreground: const Color(0xFF335C8A),
      );
    case 'ARCHIVED':
      return (
        background: const Color(0xFFEDE7E3),
        foreground: const Color(0xFF6A5B54),
      );
    default:
      return (
        background: colorScheme.surfaceContainerHighest,
        foreground: colorScheme.onSurfaceVariant,
      );
  }
}

String _formatDashboardDate(DateTime date) {
  const monthNames = <int, String>{
    1: 'Jan',
    2: 'Feb',
    3: 'Mar',
    4: 'Apr',
    5: 'May',
    6: 'Jun',
    7: 'Jul',
    8: 'Aug',
    9: 'Sep',
    10: 'Oct',
    11: 'Nov',
    12: 'Dec',
  };

  final month = monthNames[date.month] ?? '${date.month}';
  final day = date.day.toString().padLeft(2, '0');

  return '$day $month ${date.year}';
}
