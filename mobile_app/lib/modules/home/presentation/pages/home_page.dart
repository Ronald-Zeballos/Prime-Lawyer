import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../shared/localization/app_strings_context.dart';
import '../../../../shared/models/session_user.dart';
import '../../../../shared/providers/session_provider.dart';
import '../../../../shared/widgets/prime_brand_app_bar.dart';
import '../../../../shared/widgets/prime_bottom_nav.dart';
import '../../../../shared/widgets/prime_empty_state.dart';
import '../../../../shared/widgets/prime_page_scaffold.dart';
import '../../../../shared/widgets/prime_status_chip.dart';
import '../../../../shared/widgets/prime_surface_card.dart';
import '../../../case_files/domain/entities/case_file.dart';
import '../../../clients/domain/entities/client.dart';
import '../../domain/entities/home_dashboard.dart';
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
    final controller = context.watch<HomeDashboardController>();
    final sessionProvider = context.watch<SessionProvider>();
    final currentUser = sessionProvider.currentUser;
    final strings = context.strings;
    final dashboard = controller.dashboard;

    return PrimePageScaffold(
      currentTab: PrimeRootTab.home,
      appBar: PrimeBrandAppBar(
        prominentBrand: true,
        leadingIcon: Icons.settings_outlined,
        leadingTooltip: strings.openSettings,
        onLeadingPressed: () {
          Navigator.of(context).pushNamed(AppRoutes.profile);
        },
      ),
      body: Builder(
        builder: (context) {
          if (controller.isLoading && dashboard == null) {
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
                132,
              ),
              children: [
                _HomeHeroBanner(
                  currentUser: currentUser,
                ),
                if (controller.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  _ErrorMessageBanner(message: controller.errorMessage!),
                ],
                const SizedBox(height: AppTheme.sectionSpacing),
                _SectionTitle(
                  title: strings.currentSnapshot,
                  subtitle: strings.syncedWithBackend,
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    _SummaryMetricCard(
                      icon: Icons.groups_2_rounded,
                      label: strings.clientsMetricLabel,
                      value: '${dashboard?.totalClients ?? 0}',
                      caption: strings.clientsMetricCaption,
                      onTap: () =>
                          PrimeBottomNav.openTab(context, PrimeRootTab.clients),
                    ),
                    _SummaryMetricCard(
                      icon: Icons.work_rounded,
                      label: strings.totalCaseFilesMetricLabel,
                      value: '${dashboard?.totalCaseFiles ?? 0}',
                      caption: strings.totalCaseFilesMetricCaption,
                      onTap: () => PrimeBottomNav.openTab(
                        context,
                        PrimeRootTab.caseFiles,
                      ),
                    ),
                    _SummaryMetricCard(
                      icon: Icons.timelapse_rounded,
                      label: strings.activeCasesMetricLabel,
                      value: '${dashboard?.activeCaseFilesCount ?? 0}',
                      caption:
                          strings.isSpanish ? 'En progreso' : 'In progress',
                      onTap: () => PrimeBottomNav.openTab(
                        context,
                        PrimeRootTab.caseFiles,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.sectionSpacing),
                _SectionTitle(
                  title: strings.isSpanish ? 'IA Asistencia' : 'AI assistance',
                  subtitle: strings.legalAiQuestionCardDescription,
                ),
                const SizedBox(height: 14),
                _AiAssistanceCard(
                  dashboard: dashboard,
                  onOpenAi: () {
                    Navigator.of(context)
                        .pushNamed(AppRoutes.legalAiConsultation);
                  },
                  onOpenRepository: () {
                    Navigator.of(context)
                        .pushNamed(AppRoutes.knowledgeRepository);
                  },
                  onResumeCase:
                      dashboard == null || !dashboard.hasRecentCaseFiles
                          ? null
                          : () {
                              Navigator.of(context).pushNamed(
                                AppRoutes.caseFileDetail,
                                arguments: dashboard.recentCaseFiles.first.id,
                              );
                            },
                ),
                const SizedBox(height: AppTheme.sectionSpacing),
                _SectionTitle(
                  title: strings.recentActivityTitle,
                  subtitle: strings.workspaceDescription,
                ),
                const SizedBox(height: 14),
                _RecentActivityCard(
                  dashboard: dashboard,
                  onOpenCaseFile: (caseFileId) {
                    Navigator.of(context).pushNamed(
                      AppRoutes.caseFileDetail,
                      arguments: caseFileId,
                    );
                  },
                  onOpenClients: () {
                    PrimeBottomNav.openTab(context, PrimeRootTab.clients);
                  },
                  onOpenCaseFiles: () {
                    PrimeBottomNav.openTab(context, PrimeRootTab.caseFiles);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HomeHeroBanner extends StatelessWidget {
  const _HomeHeroBanner({
    required this.currentUser,
  });

  final SessionUser? currentUser;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppTheme.primaryNavy,
            AppTheme.secondaryNavy,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(34),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PrimeStatusChip.accent(
            strings.isSpanish ? 'Prime workspace' : 'Prime workspace',
          ),
          const SizedBox(height: 18),
          Text(
            currentUser == null
                ? strings.welcomeBack
                : strings.welcomeUser(currentUser!.displayLabel),
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppTheme.surface,
                ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
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
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _SummaryMetricCard extends StatelessWidget {
  const _SummaryMetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.caption,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final String caption;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final availableWidth =
        MediaQuery.of(context).size.width - (AppTheme.pagePadding * 2) - 14;

    return SizedBox(
      width: availableWidth * 0.5,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        onTap: onTap,
        child: PrimeSurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.softBeige,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryNavy,
                  size: 24,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                value,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppTheme.primaryNavy,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                caption,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AiAssistanceCard extends StatelessWidget {
  const _AiAssistanceCard({
    required this.dashboard,
    required this.onOpenAi,
    required this.onOpenRepository,
    required this.onResumeCase,
  });

  final HomeDashboard? dashboard;
  final VoidCallback onOpenAi;
  final VoidCallback onOpenRepository;
  final VoidCallback? onResumeCase;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return PrimeSurfaceCard(
      color: const Color(0xFFFAF7F1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryNavy,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppTheme.accentGold,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.consultLegalAi,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      strings.legalAiConsultationSubtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onOpenAi,
            icon: const Icon(Icons.auto_awesome_rounded),
            label: Text(strings.aiSubmitQuestion),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onOpenRepository,
            icon: const Icon(Icons.library_books_outlined),
            label: Text(strings.openKnowledgeRepository),
          ),
          if (onResumeCase != null && dashboard != null) ...[
            const SizedBox(height: 14),
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onResumeCase,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.softBeige,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.play_circle_outline_rounded,
                      color: AppTheme.primaryNavy,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        strings.resumeCaseFile(
                          dashboard!.recentCaseFiles.first.internalCode,
                        ),
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: AppTheme.primaryNavy,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard({
    required this.dashboard,
    required this.onOpenCaseFile,
    required this.onOpenClients,
    required this.onOpenCaseFiles,
  });

  final HomeDashboard? dashboard;
  final ValueChanged<String> onOpenCaseFile;
  final VoidCallback onOpenClients;
  final VoidCallback onOpenCaseFiles;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return PrimeSurfaceCard(
      child: dashboard == null ||
              (!dashboard!.hasRecentClients && !dashboard!.hasRecentCaseFiles)
          ? PrimeEmptyState(
              icon: Icons.assignment_outlined,
              title: strings.isSpanish
                  ? 'Aún no hay actividad reciente'
                  : 'No recent activity yet',
              description: strings.workspaceDescription,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (dashboard!.hasRecentCaseFiles) ...[
                  Text(
                    strings.recentCaseFilesTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  for (final caseFile
                      in dashboard!.recentCaseFiles.take(3)) ...[
                    _RecentCaseTile(
                      caseFile: caseFile,
                      onOpen: () => onOpenCaseFile(caseFile.id),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
                if (dashboard!.hasRecentClients) ...[
                  const SizedBox(height: 8),
                  Text(
                    strings.recentClientsTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  for (final client in dashboard!.recentClients.take(3)) ...[
                    _RecentClientTile(client: client),
                    const SizedBox(height: 10),
                  ],
                ],
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    OutlinedButton.icon(
                      onPressed: onOpenClients,
                      icon: const Icon(Icons.groups_2_outlined),
                      label: Text(strings.manageClients),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: onOpenCaseFiles,
                      icon: const Icon(Icons.work_outline_rounded),
                      label: Text(strings.manageCaseFiles),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _RecentCaseTile extends StatelessWidget {
  const _RecentCaseTile({
    required this.caseFile,
    required this.onOpen,
  });

  final CaseFile caseFile;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.appBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.softBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.infoSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: AppTheme.primaryNavy,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  caseFile.internalCode,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  caseFile.title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    PrimeStatusChip.caseStatus(
                      status: caseFile.status,
                      label: strings.caseStatus(caseFile.status),
                    ),
                    PrimeStatusChip.neutral(caseFile.processType),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: onOpen,
            child: Text(strings.openCaseFileAction),
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
    final initials = '${client.firstName.isNotEmpty ? client.firstName[0] : ''}'
            '${client.lastName.isNotEmpty ? client.lastName[0] : ''}'
        .toUpperCase();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.appBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.softBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppTheme.softBeige,
            foregroundColor: AppTheme.primaryNavy,
            child: Text(
              initials.isEmpty ? 'PL' : initials,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
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
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
        ],
      ),
    );
  }
}

class _ErrorMessageBanner extends StatelessWidget {
  const _ErrorMessageBanner({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.errorSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.error.withValues(alpha: 0.18)),
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
