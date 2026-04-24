import 'package:flutter/material.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_theme.dart';
import 'prime_lawyer_logo.dart';

class PrimeBrandAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PrimeBrandAppBar({
    super.key,
    this.title,
    this.leadingIcon,
    this.leadingTooltip,
    this.onLeadingPressed,
    this.actions = const [],
    this.prominentBrand = false,
  });

  final String? title;
  final IconData? leadingIcon;
  final String? leadingTooltip;
  final VoidCallback? onLeadingPressed;
  final List<Widget> actions;
  final bool prominentBrand;

  @override
  Size get preferredSize => Size.fromHeight(prominentBrand ? 104 : 96);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: preferredSize.height,
      titleSpacing: leadingIcon == null ? AppTheme.pagePadding : 0,
      leadingWidth: leadingIcon == null ? 0 : 72,
      leading: leadingIcon == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(left: 18),
              child: PrimeHeaderIconButton(
                icon: leadingIcon!,
                tooltip: leadingTooltip,
                onPressed:
                    onLeadingPressed ?? () => _handleDefaultBack(context),
              ),
            ),
      title: prominentBrand
          ? const Align(
              alignment: Alignment.centerLeft,
              child: PrimeLawyerLogo(height: 42),
            )
          : _PrimeBrandTitle(title: title),
      actions: [
        for (final action in actions)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: action,
          ),
        const SizedBox(width: 10),
      ],
    );
  }

  void _handleDefaultBack(BuildContext context) {
    final navigator = Navigator.of(context);

    if (navigator.canPop()) {
      navigator.pop();
      return;
    }

    navigator.pushNamedAndRemoveUntil(
      AppRoutes.home,
      (route) => route.isFirst,
    );
  }
}

class PrimeHeaderIconButton extends StatelessWidget {
  const PrimeHeaderIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.isSelected = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final child = Material(
      color: isSelected ? AppTheme.softBeige : AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppTheme.softBorder),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onPressed,
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(
            icon,
            color: onPressed == null
                ? AppTheme.textSecondary.withValues(alpha: 0.45)
                : AppTheme.primaryNavy,
            size: 22,
          ),
        ),
      ),
    );

    if (tooltip == null || tooltip!.trim().isEmpty) {
      return child;
    }

    return Tooltip(
      message: tooltip!,
      child: child,
    );
  }
}

class _PrimeBrandTitle extends StatelessWidget {
  const _PrimeBrandTitle({
    required this.title,
  });

  final String? title;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PrimeLawyerLogo(height: 26),
        if (title != null) ...[
          const SizedBox(height: 10),
          Text(
            title!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ],
    );
  }
}
