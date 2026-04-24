import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import 'prime_bottom_nav.dart';

class PrimePageScaffold extends StatelessWidget {
  const PrimePageScaffold({
    super.key,
    required this.body,
    required this.appBar,
    this.currentTab,
    this.floatingActionButton,
    this.floatingActionButtonLocation = FloatingActionButtonLocation.endFloat,
    this.extendBody = false,
  });

  final Widget body;
  final PreferredSizeWidget appBar;
  final PrimeRootTab? currentTab;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation floatingActionButtonLocation;
  final bool extendBody;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: extendBody,
      backgroundColor: AppTheme.appBackground,
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar:
          currentTab == null ? null : PrimeBottomNav(currentTab: currentTab!),
    );
  }
}
