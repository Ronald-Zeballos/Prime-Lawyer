import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../shared/localization/app_strings_context.dart';
import '../../../../shared/models/session_user.dart';
import '../../../../shared/providers/session_provider.dart';
import '../../../case_files/domain/entities/case_file.dart';
import '../../../clients/domain/entities/client.dart';
import '../../../documents/presentation/pages/documents_page.dart';
import '../../domain/usecases/get_home_dashboard_use_case.dart';
import '../controllers/home_dashboard_controller.dart';

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
    final strings = context.strings;
    final sessionProvider = context.watch<SessionProvider>();
    final dashboardController = context.watch<HomeDashboardController>();
    final currentUser = sessionProvider.currentUser;
    final dashboard = dashboardController.dashboard;
    final spotlightCase =
        dashboard != null && dashboard.recentCaseFiles.isNotEmpty
            ? dashboard.recentCaseFiles.first
            : null;

    if (dashboardController.isLoading && dashboard == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F3EB),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0E5B45),
          foregroundColor: Colors.white,
          title: Text(strings.appName),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F3EB),
      drawer: _HomeDrawer(recentCaseFile: spotlightCase),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E5B45),
        foregroundColor: Colors.white,
        title: Text(strings.appName),
        actions: [
          IconButton(
            onPressed: dashboardController.refresh,
            tooltip: strings.refreshDashboard,
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.profile);
            },
            tooltip: strings.openSettings,
            icon: const Icon(Icons.tune_rounded),
          ),
          IconButton(
            onPressed: () async {
              await context.read<SessionProvider>().clearSession();
            },
            tooltip: strings.signOut,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Stack(
        children: [
          const _HomeTopDecoration(),
          RefreshIndicator(
            onRefresh: dashboardController.refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                _HeroBanner(
                  currentUser: currentUser,
                  totalClients: dashboard?.totalClients ?? 0,
                  totalCaseFiles: dashboard?.totalCaseFiles ?? 0,
                  activeCaseFilesCount: dashboard?.activeCaseFilesCount ?? 0,
                ),
                if (dashboardController.isLoading && dashboard != null) ...[
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: const LinearProgressIndicator(minHeight: 4),
                  ),
                ],
                if (dashboardController.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  _StatusBanner(
                    message: dashboardController.errorMessage!,
                    onDismiss: dashboardController.clearError,
                  ),
                ],
                const SizedBox(height: 24),
                _SectionHeading(
                  title: strings.quickActionsTitle,
                  subtitle: strings.workspaceDescription,
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth >= 720 ? 4 : 2;

                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: crossAxisCount == 4 ? 1.2 : 1.02,
                      children: [
                        _QuickActionCard(
                          icon: Icons.people_alt_outlined,
                          title: strings.manageClients,
                          subtitle: strings.clientsActionDescription,
                          accentColor: const Color(0xFF0E5B45),
                          onTap: () {
                            Navigator.of(context).pushNamed(AppRoutes.clients);
                          },
                        ),
                        _QuickActionCard(
                          icon: Icons.folder_open_outlined,
                          title: strings.manageCaseFiles,
                          subtitle: strings.caseFilesActionDescription,
                          accentColor: const Color(0xFFC89A3D),
                          onTap: () {
                            Navigator.of(context).pushNamed(AppRoutes.caseFiles);
                          },
                        ),
                        _QuickActionCard(
                          icon: Icons.description_outlined,
                          title: strings.openRecentDocumentsTitle,
                          subtitle: spotlightCase == null
                              ? strings.documentsActionFallbackDescription
                              : strings.documentsActionDescription(
                                  spotlightCase.internalCode,
                                ),
                          accentColor: const Color(0xFF315F8A),
                          onTap: () {
                            if (spotlightCase == null) {
                              Navigator.of(context).pushNamed(AppRoutes.caseFiles);
                              return;
                            }

                            _openDocuments(context, spotlightCase);
                          },
                        ),
                        _QuickActionCard(
                          icon: Icons.tune_rounded,
                          title: strings.settingsActionTitle,
                          subtitle: strings.settingsActionDescription,
                          accentColor: const Color(0xFF6A5B54),
                          onTap: () {
                            Navigator.of(context).pushNamed(AppRoutes.profile);
                          },
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                _SectionHeading(
                  title: strings.currentSnapshot,
                  subtitle: strings.syncedWithBackend,
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth >= 720 ? 3 : 2;

                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: crossAxisCount == 3 ? 1.35 : 1.18,
                      children: [
                        _DashboardMetricCard(
                          icon: Icons.people_alt_outlined,
                          label: strings.clientsMetricLabel,
                          value: '${dashboard?.totalClients ?? 0}',
                          caption: strings.clientsMetricCaption,
                          accentColor: const Color(0xFF0E5B45),
                        ),
                        _DashboardMetricCard(
                          icon: Icons.folder_special_outlined,
                          label: strings.totalCaseFilesMetricLabel,
                          value: '${dashboard?.totalCaseFiles ?? 0}',
                          caption: strings.totalCaseFilesMetricCaption,
                          accentColor: const Color(0xFFC89A3D),
                        ),
                        _DashboardMetricCard(
                          icon: Icons.gavel_rounded,
                          label: strings.activeCasesMetricLabel,
                          value: '${dashboard?.activeCaseFilesCount ?? 0}',
                          caption: strings.activeCasesMetricCaption,
                          accentColor: const Color(0xFF315F8A),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  strings.recentActivityTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  title: strings.recentCaseFilesTitle,
                  actionLabel: strings.viewAll,
                  onActionTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.caseFiles);
                  },
                  child: dashboard == null || !dashboard.hasRecentCaseFiles
                      ? _EmptySectionMessage(
                          icon: Icons.create_new_folder_outlined,
                          title: strings.noCaseFilesTitle,
                          description: strings.noCaseFilesDescription,
                        )
                      : Column(
                          children: [
                            for (final caseFile in dashboard.recentCaseFiles)
                              _RecentCaseFileTile(
                                caseFile: caseFile,
                                clientLabel:
                                    dashboard.clientLabelFor(caseFile.clientId),
                                onOpen: () {
                                  Navigator.of(context).pushNamed(
                                    AppRoutes.caseFileDetail,
                                    arguments: caseFile.id,
                                  );
                                },
                                onOpenDocuments: () {
                                  _openDocuments(context, caseFile);
                                },
                              ),
                          ],
                        ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: strings.recentClientsTitle,
                  actionLabel: strings.viewAll,
                  onActionTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.clients);
                  },
                  child: dashboard == null || !dashboard.hasRecentClients
                      ? _EmptySectionMessage(
                          icon: Icons.person_add_alt_1_rounded,
                          title: strings.noClientsTitle,
                          description: strings.noClientsDescription,
                        )
                      : Column(
                          children: [
                            for (final client in dashboard.recentClients)
                              _RecentClientTile(client: client),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openDocuments(BuildContext context, CaseFile caseFile) {
    Navigator.of(context).pushNamed(
      AppRoutes.documents,
      arguments: DocumentsPageArgs(
        caseFileId: caseFile.id,
        caseFileTitle: caseFile.internalCode,
      ),
    );
  }
}

class _HomeTopDecoration extends StatelessWidget {
  const _HomeTopDecoration();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        height: 220,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0E5B45),
                Color(0xFF174336),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: const [
              Positioned(
                top: -50,
                right: -20,
                child: _BackdropCircle(
                  size: 150,
                  color: Color(0x14FFFFFF),
                ),
              ),
              Positioned(
                top: 88,
                left: -28,
                child: _BackdropCircle(
                  size: 104,
                  color: Color(0x12FFFFFF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackdropCircle extends StatelessWidget {
  const _BackdropCircle({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.currentUser,
    required this.totalClients,
    required this.totalCaseFiles,
    required this.activeCaseFilesCount,
  });

  final SessionUser? currentUser;
  final int totalClients;
  final int totalCaseFiles;
  final int activeCaseFilesCount;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final fullName =
        currentUser == null ? strings.noUserRoleFallback : currentUser!.fullName;
    final firstName = currentUser == null
        ? strings.noUserRoleFallback
        : currentUser!.firstName;
    final role =
        currentUser == null ? strings.noUserRoleFallback : currentUser!.role;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0E5B45),
            Color(0xFF174336),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x20FFFFFF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          strings.dashboardTitle,
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        currentUser == null
                            ? strings.welcomeBack
                            : strings.welcomeUser(firstName),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        currentUser == null
                            ? strings.heroGuestMessage
                            : strings.heroUserMessage(fullName, role),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: const Color(0xE9FFFFFF),
                              height: 1.4,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0x16FFFFFF),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0x26FFFFFF),
                    ),
                  ),
                  child: const Icon(
                    Icons.gavel_rounded,
                    color: Color(0xFFC89A3D),
                    size: 30,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _HeroPill(
                  icon: Icons.verified_user_outlined,
                  label: role,
                ),
                _HeroPill(
                  icon: Icons.bolt_rounded,
                  label: strings.sessionStatusReady,
                ),
                _HeroPill(
                  icon: Icons.people_alt_outlined,
                  label: strings.clientsCount(totalClients),
                ),
                _HeroPill(
                  icon: Icons.folder_open_outlined,
                  label: strings.caseFilesCount(totalCaseFiles),
                ),
                _HeroPill(
                  icon: Icons.gavel_rounded,
                  label: strings.activeCasesCount(activeCaseFilesCount),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0x12FFFFFF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0x22FFFFFF),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0x16FFFFFF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.radar_rounded,
                      color: Color(0xFFC89A3D),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      strings.sessionStatusDescription,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xE9FFFFFF),
                            height: 1.35,
                          ),
                    ),
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

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0x20FFFFFF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: const Color(0xFFC89A3D),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFDAD1C4),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: accentColor.withAlpha(31),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: accentColor,
                  ),
                ),
                const Spacer(),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                ),
              ],
            ),
          ),
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
    required this.accentColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final String caption;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accentColor.withAlpha(31),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: accentColor,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
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
            Text(
              caption,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.message,
    required this.onDismiss,
  });

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFBE7E5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFF0C5BF),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                height: 1.35,
              ),
            ),
          ),
          IconButton(
            onPressed: onDismiss,
            icon: const Icon(Icons.close_rounded),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.actionLabel,
    this.onActionTap,
  });

  final String title;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                if (actionLabel != null && onActionTap != null)
                  TextButton(
                    onPressed: onActionTap,
                    child: Text(actionLabel!),
                  ),
              ],
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
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0x140E5B45),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF0E5B45),
            ),
          ),
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
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.35,
                      ),
                ),
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
    final strings = context.strings;

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
              radius: 24,
              backgroundColor: const Color(0x140E5B45),
              foregroundColor: const Color(0xFF0E5B45),
              child: Text(
                client.firstName.isEmpty
                    ? '?'
                    : client.firstName[0].toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
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
                  Text('${strings.documentFieldLabel}: ${client.documentNumber}'),
                  const SizedBox(height: 4),
                  Text(strings.createdOn(strings.formatShortDate(client.createdAt))),
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
    required this.clientLabel,
    required this.onOpen,
    required this.onOpenDocuments,
  });

  final CaseFile caseFile;
  final String clientLabel;
  final VoidCallback onOpen;
  final VoidCallback onOpenDocuments;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        caseFile.internalCode,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        caseFile.subject,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _CaseStatusChip(status: caseFile.status),
              ],
            ),
            const SizedBox(height: 10),
            Text('${strings.clientLabel}: $clientLabel'),
            const SizedBox(height: 4),
            Text(
              '${strings.openedAtLabel}: ${strings.formatShortDate(caseFile.openedAt)}',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.tonalIcon(
                  onPressed: onOpen,
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: Text(strings.openCaseFileAction),
                ),
                OutlinedButton.icon(
                  onPressed: onOpenDocuments,
                  icon: const Icon(Icons.description_outlined),
                  label: Text(strings.openDocuments),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeDrawer extends StatelessWidget {
  const _HomeDrawer({
    required this.recentCaseFile,
  });

  final CaseFile? recentCaseFile;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final currentUser = context.watch<SessionProvider>().currentUser;
    final displayName =
        currentUser == null ? strings.noUserRoleFallback : currentUser.fullName;
    final role =
        currentUser == null ? strings.noUserRoleFallback : currentUser.role;
    final email =
        currentUser == null ? 'admin@demo.com' : currentUser.email;
    final initials = displayName
        .split(' ')
        .where((chunk) => chunk.isNotEmpty)
        .take(2)
        .map((chunk) => chunk[0].toUpperCase())
        .join();

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0E5B45),
                    Color(0xFF174336),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0x16FFFFFF),
                    foregroundColor: Colors.white,
                    child: Text(
                      initials.isEmpty ? 'PL' : initials,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    displayName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xD9FFFFFF),
                        ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x16FFFFFF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      role,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                    child: Text(
                      strings.navigationLabel,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  _DrawerEntry(
                    icon: Icons.dashboard_outlined,
                    label: strings.overviewLabel,
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  _DrawerEntry(
                    icon: Icons.people_alt_outlined,
                    label: strings.clientsTitle,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed(AppRoutes.clients);
                    },
                  ),
                  _DrawerEntry(
                    icon: Icons.folder_open_outlined,
                    label: strings.caseFilesTitle,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed(AppRoutes.caseFiles);
                    },
                  ),
                  _DrawerEntry(
                    icon: Icons.description_outlined,
                    label: strings.documentsTitle,
                    onTap: () {
                      Navigator.of(context).pop();

                      if (recentCaseFile == null) {
                        Navigator.of(context).pushNamed(AppRoutes.caseFiles);
                        return;
                      }

                      Navigator.of(context).pushNamed(
                        AppRoutes.documents,
                        arguments: DocumentsPageArgs(
                          caseFileId: recentCaseFile!.id,
                          caseFileTitle: recentCaseFile!.internalCode,
                        ),
                      );
                    },
                  ),
                  _DrawerEntry(
                    icon: Icons.tune_rounded,
                    label: strings.settingsTitle,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed(AppRoutes.profile);
                    },
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
              decoration: const BoxDecoration(
                color: Color(0xFFF1E8DB),
              ),
              child: FilledButton.icon(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await context.read<SessionProvider>().clearSession();
                },
                icon: const Icon(Icons.logout_rounded),
                label: Text(strings.signOut),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerEntry extends StatelessWidget {
  const _DrawerEntry({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: Icon(icon),
        title: Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        onTap: onTap,
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
    final strings = context.strings;
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
        strings.caseStatus(status),
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
