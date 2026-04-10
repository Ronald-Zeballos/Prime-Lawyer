import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/localization/app_strings_context.dart';
import '../../../../shared/models/app_language.dart';
import '../../../../shared/providers/app_language_provider.dart';
import '../../../../shared/providers/session_provider.dart';

class ProfileSettingsPage extends StatelessWidget {
  const ProfileSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final currentUser = context.watch<SessionProvider>().currentUser;
    final languageProvider = context.watch<AppLanguageProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.settingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.accountTitle,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentUser == null
                        ? strings.notSignedInYet
                        : strings.signedInAs(
                            currentUser.fullName,
                            currentUser.role,
                          ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F2EA),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(strings.passwordChangeComingSoon),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.languageTitle,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(strings.languageDescription),
                  const SizedBox(height: 16),
                  SegmentedButton<AppLanguage>(
                    segments: [
                      for (final language in AppLanguage.values)
                        ButtonSegment<AppLanguage>(
                          value: language,
                          label: Text(strings.languageName(language)),
                        ),
                    ],
                    selected: {languageProvider.currentLanguage},
                    onSelectionChanged: (selection) {
                      if (selection.isEmpty) {
                        return;
                      }

                      context
                          .read<AppLanguageProvider>()
                          .setLanguage(selection.first);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
