import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

class PrimeSurfaceCard extends StatelessWidget {
  const PrimeSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color = AppTheme.surface,
    this.borderColor = AppTheme.softBorder,
    this.radius = AppTheme.cardRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color borderColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
