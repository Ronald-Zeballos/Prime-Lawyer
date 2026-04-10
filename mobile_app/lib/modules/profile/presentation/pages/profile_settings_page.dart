import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/services/api_health_service.dart';
import '../../../../shared/localization/app_strings_context.dart';
import '../../../../shared/models/app_language.dart';
import '../../../../shared/providers/api_base_url_provider.dart';
import '../../../../shared/providers/app_language_provider.dart';
import '../../../../shared/providers/session_provider.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final _apiBaseUrlFormKey = GlobalKey<FormState>();
  late final TextEditingController _apiBaseUrlController;
  String? _lastSyncedApiBaseUrl;

  @override
  void initState() {
    super.initState();
    _apiBaseUrlController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final currentApiBaseUrl =
        context.read<ApiBaseUrlProvider>().currentApiBaseUrl;

    if (_lastSyncedApiBaseUrl == currentApiBaseUrl) {
      return;
    }

    _apiBaseUrlController.text = currentApiBaseUrl;
    _lastSyncedApiBaseUrl = currentApiBaseUrl;
  }

  @override
  void dispose() {
    _apiBaseUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final currentUser = context.watch<SessionProvider>().currentUser;
    final languageProvider = context.watch<AppLanguageProvider>();
    final apiBaseUrlProvider = context.watch<ApiBaseUrlProvider>();

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
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.apiConnectionTitle,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(strings.apiConnectionDescription),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F2EA),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(apiBaseUrlProvider.currentApiBaseUrl),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    strings.realDeviceApiHint,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Form(
                    key: _apiBaseUrlFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _apiBaseUrlController,
                          keyboardType: TextInputType.url,
                          decoration: InputDecoration(
                            labelText: strings.apiBaseUrlLabel,
                            hintText: strings.apiBaseUrlHint,
                          ),
                          validator: (value) {
                            final normalizedValue = value?.trim() ?? '';

                            if (normalizedValue.isEmpty) {
                              return strings.apiBaseUrlRequiredError;
                            }

                            final parsedUri = Uri.tryParse(normalizedValue);

                            if (parsedUri == null ||
                                !parsedUri.hasScheme ||
                                !parsedUri.hasAuthority) {
                              return strings.apiBaseUrlInvalidError;
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => _saveApiBaseUrl(context),
                          icon: const Icon(Icons.save_outlined),
                          label: Text(strings.saveApiBaseUrl),
                        ),
                        const SizedBox(height: 10),
                        FilledButton.tonalIcon(
                          onPressed: () => _testApiConnection(context),
                          icon: const Icon(Icons.wifi_tethering_rounded),
                          label: Text(strings.testApiConnection),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: () => _resetApiBaseUrl(context),
                          icon: const Icon(Icons.restart_alt_rounded),
                          label: Text(strings.resetApiBaseUrl),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveApiBaseUrl(BuildContext context) async {
    if (!_apiBaseUrlFormKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    await context.read<ApiBaseUrlProvider>().setApiBaseUrl(
          _apiBaseUrlController.text,
        );

    if (!mounted) {
      return;
    }

    _lastSyncedApiBaseUrl = context.read<ApiBaseUrlProvider>().currentApiBaseUrl;
    _apiBaseUrlController.text = _lastSyncedApiBaseUrl!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.strings.apiBaseUrlSaved),
      ),
    );
  }

  Future<void> _resetApiBaseUrl(BuildContext context) async {
    FocusScope.of(context).unfocus();

    await context.read<ApiBaseUrlProvider>().resetToDefault();

    if (!mounted) {
      return;
    }

    _lastSyncedApiBaseUrl = context.read<ApiBaseUrlProvider>().currentApiBaseUrl;
    _apiBaseUrlController.text = _lastSyncedApiBaseUrl!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.strings.apiBaseUrlReset),
      ),
    );
  }

  Future<void> _testApiConnection(BuildContext context) async {
    FocusScope.of(context).unfocus();

    if (!_apiBaseUrlFormKey.currentState!.validate()) {
      return;
    }

    await context.read<ApiBaseUrlProvider>().setApiBaseUrl(
          _apiBaseUrlController.text,
        );

    if (!mounted) {
      return;
    }

    final strings = context.strings;
    final messenger = ScaffoldMessenger.of(context);

    try {
      final isHealthy = await context.read<ApiHealthService>().ping();

      if (!mounted) {
        return;
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            isHealthy
                ? strings.apiConnectionSuccess
                : strings.apiConnectionFailure,
          ),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text(error.message),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text(strings.apiConnectionFailure),
        ),
      );
    }
  }
}
