import 'package:flutter/material.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_theme.dart';
import '../localization/app_strings_context.dart';

enum PrimeRootTab {
  clients,
  caseFiles,
  home,
  marketplace,
  profile,
}

class PrimeBottomNav extends StatelessWidget {
  const PrimeBottomNav({
    super.key,
    required this.currentTab,
  });

  final PrimeRootTab currentTab;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 114,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 20,
            right: 20,
            bottom: 16,
            child: Container(
              height: 76,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(36),
                border: Border.all(color: AppTheme.softBorder),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _PrimeNavItem(
                      icon: Icons.groups_2_outlined,
                      activeIcon: Icons.groups_2_rounded,
                      label: context.strings.isSpanish ? 'Clientes' : 'Clients',
                      isActive: currentTab == PrimeRootTab.clients,
                      onTap: currentTab == PrimeRootTab.clients
                          ? null
                          : () => openTab(context, PrimeRootTab.clients),
                    ),
                  ),
                  Expanded(
                    child: _PrimeNavItem(
                      icon: Icons.work_outline_rounded,
                      activeIcon: Icons.work_rounded,
                      label: context.strings.isSpanish ? 'Casos' : 'Cases',
                      isActive: currentTab == PrimeRootTab.caseFiles,
                      onTap: currentTab == PrimeRootTab.caseFiles
                          ? null
                          : () => openTab(context, PrimeRootTab.caseFiles),
                    ),
                  ),
                  const SizedBox(width: 86),
                  Expanded(
                    child: _PrimeNavItem(
                      icon: Icons.storefront_outlined,
                      activeIcon: Icons.storefront_rounded,
                      label: context.strings.isSpanish
                          ? 'Marketplace'
                          : 'Marketplace',
                      isActive: currentTab == PrimeRootTab.marketplace,
                      onTap: currentTab == PrimeRootTab.marketplace
                          ? null
                          : () => openTab(context, PrimeRootTab.marketplace),
                    ),
                  ),
                  Expanded(
                    child: _PrimeNavItem(
                      icon: Icons.person_outline_rounded,
                      activeIcon: Icons.person_rounded,
                      label: context.strings.isSpanish ? 'Perfil' : 'Profile',
                      isActive: currentTab == PrimeRootTab.profile,
                      onTap: currentTab == PrimeRootTab.profile
                          ? null
                          : () => openTab(context, PrimeRootTab.profile),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -2,
            child: _PrimeHomeButton(
              isActive: currentTab == PrimeRootTab.home,
              label: context.strings.isSpanish ? 'Inicio' : 'Home',
              onTap: currentTab == PrimeRootTab.home
                  ? null
                  : () => openTab(context, PrimeRootTab.home),
            ),
          ),
        ],
      ),
    );
  }

  static void openTab(BuildContext context, PrimeRootTab tab) {
    final route = _routeForTab(tab);

    if (ModalRoute.of(context)?.settings.name == route) {
      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil(
      route,
      (existingRoute) => existingRoute.isFirst,
    );
  }

  static String _routeForTab(PrimeRootTab tab) {
    switch (tab) {
      case PrimeRootTab.clients:
        return AppRoutes.clients;
      case PrimeRootTab.caseFiles:
        return AppRoutes.caseFiles;
      case PrimeRootTab.home:
        return AppRoutes.home;
      case PrimeRootTab.marketplace:
        return AppRoutes.contractMarketplace;
      case PrimeRootTab.profile:
        return AppRoutes.profile;
    }
  }
}

class _PrimeNavItem extends StatelessWidget {
  const _PrimeNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppTheme.primaryNavy : AppTheme.textSecondary;

    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isActive ? activeIcon : icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimeHomeButton extends StatelessWidget {
  const _PrimeHomeButton({
    required this.isActive,
    required this.label,
    required this.onTap,
  });

  final bool isActive;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: AppTheme.primaryNavy,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.appBackground,
              width: 6,
            ),
            boxShadow: [
              ...AppTheme.cardShadow,
              BoxShadow(
                color: AppTheme.primaryNavy.withValues(alpha: 0.14),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.home_rounded,
                color: isActive ? AppTheme.accentGold : AppTheme.surface,
                size: 26,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isActive ? AppTheme.accentGold : AppTheme.surface,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
