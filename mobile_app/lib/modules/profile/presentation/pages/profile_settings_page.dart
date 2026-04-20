import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/services/api_health_service.dart';
import '../../../../shared/localization/app_strings_context.dart';
import '../../../../shared/models/app_language.dart';
import '../../../../shared/providers/api_base_url_provider.dart';
import '../../../../shared/providers/app_language_provider.dart';
import '../../../../shared/providers/session_provider.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/get_my_profile_use_case.dart';
import '../../domain/usecases/update_my_profile_use_case.dart';
import '../controllers/profile_controller.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final _apiBaseUrlFormKey = GlobalKey<FormState>();
  final _profileFormKey = GlobalKey<FormState>();
  late final TextEditingController _apiBaseUrlController;
  late final TextEditingController _displayNameController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _bioController;
  String? _lastSyncedApiBaseUrl;
  String? _lastSyncedProfileSignature;
  String? _apiFeedbackMessage;
  bool _apiFeedbackIsError = false;
  bool _isApiActionInProgress = false;

  @override
  void initState() {
    super.initState();
    _apiBaseUrlController = TextEditingController();
    _displayNameController = TextEditingController();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _bioController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final apiBaseUrlProvider = context.read<ApiBaseUrlProvider>();
    final currentApiBaseUrl = apiBaseUrlProvider.hasManualOverride
        ? apiBaseUrlProvider.currentApiBaseUrl
        : '';

    if (_lastSyncedApiBaseUrl == currentApiBaseUrl) {
      return;
    }

    _apiBaseUrlController.text = currentApiBaseUrl;
    _lastSyncedApiBaseUrl = currentApiBaseUrl;
  }

  @override
  void dispose() {
    _apiBaseUrlController.dispose();
    _displayNameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProfileController>(
      create: (context) {
        final controller = ProfileController(
          getMyProfileUseCase: context.read<GetMyProfileUseCase>(),
          updateMyProfileUseCase: context.read<UpdateMyProfileUseCase>(),
          sessionProvider: context.read<SessionProvider>(),
        );

        if (context.read<SessionProvider>().isAuthenticated) {
          controller.loadProfile();
        }

        return controller;
      },
      child: Builder(
        builder: (context) {
          final strings = context.strings;
          final sessionProvider = context.watch<SessionProvider>();
          final currentUser = sessionProvider.currentUser;
          final languageProvider = context.watch<AppLanguageProvider>();
          final apiBaseUrlProvider = context.watch<ApiBaseUrlProvider>();
          final profileController = context.watch<ProfileController>();
          final profile = profileController.profile;
          final isAuthenticated = sessionProvider.isAuthenticated;
          final resolvedApiBaseUrl =
              apiBaseUrlProvider.currentApiBaseUrl.trim();
          final displayedApiBaseUrl = resolvedApiBaseUrl.isEmpty
              ? strings.apiAutoDetecting
              : resolvedApiBaseUrl;
          final apiModeLabel = apiBaseUrlProvider.hasManualOverride
              ? strings.apiCurrentModeManual
              : strings.apiCurrentModeAuto;

          _syncProfileFields(profile);

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
                                  currentUser.displayLabel,
                                  currentUser.role,
                                ),
                        ),
                        if (profile != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F2EA),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    '${strings.profileTypeLabel}: ${profile.type}'),
                                const SizedBox(height: 6),
                                Text(
                                    '${strings.profilePlanLabel}: ${profile.plan}'),
                                const SizedBox(height: 6),
                                Text(strings.profileTokensLabel(
                                    profile.tokensAvailable)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            strings.profileUpgradeHint,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
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
                          strings.profileSectionTitle,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(strings.profileSectionDescription),
                        const SizedBox(height: 16),
                        if (!isAuthenticated)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F2EA),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(strings.profileRequiresSession),
                          )
                        else ...[
                          if (profileController.errorMessage != null) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFBE7E5),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                profileController.errorMessage!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (profileController.isLoading && profile == null)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else
                            Form(
                              key: _profileFormKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextFormField(
                                    controller: _displayNameController,
                                    decoration: InputDecoration(
                                      labelText:
                                          strings.profileDisplayNameLabel,
                                    ),
                                    validator: (value) {
                                      if ((value?.trim().length ?? 0) > 120) {
                                        return strings
                                            .profileDisplayNameTooLong;
                                      }

                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _firstNameController,
                                    decoration: InputDecoration(
                                      labelText: strings.firstNameLabel,
                                    ),
                                    validator: (value) {
                                      final normalizedValue =
                                          value?.trim() ?? '';

                                      if (normalizedValue.isEmpty) {
                                        return strings.firstNameRequiredError;
                                      }

                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _lastNameController,
                                    decoration: InputDecoration(
                                      labelText: strings.lastNameLabel,
                                    ),
                                    validator: (value) {
                                      final normalizedValue =
                                          value?.trim() ?? '';

                                      if (normalizedValue.isEmpty) {
                                        return strings.lastNameRequiredError;
                                      }

                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _bioController,
                                    minLines: 3,
                                    maxLines: 5,
                                    decoration: InputDecoration(
                                      labelText: strings.profileBioLabel,
                                      hintText: strings.profileBioHint,
                                    ),
                                    validator: (value) {
                                      if ((value?.trim().length ?? 0) > 500) {
                                        return strings.profileBioTooLong;
                                      }

                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  FilledButton.icon(
                                    onPressed: profileController.isSaving
                                        ? null
                                        : () => _saveProfile(context),
                                    icon: const Icon(Icons.save_outlined),
                                    label: Text(
                                      profileController.isSaving
                                          ? strings.savingProfile
                                          : strings.saveProfileAction,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
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
                          child: Text(displayedApiBaseUrl),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          apiModeLabel,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (apiBaseUrlProvider.isResolving) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  strings.apiAutoDetecting,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        ],
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
                                  helperText: strings.apiManualOverrideHint,
                                ),
                                validator: (value) {
                                  final normalizedValue = value?.trim() ?? '';

                                  if (normalizedValue.isEmpty) {
                                    return strings.apiBaseUrlRequiredError;
                                  }

                                  final parsedUri =
                                      Uri.tryParse(normalizedValue);

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
                                onPressed: _isApiActionInProgress
                                    ? null
                                    : () => _saveApiBaseUrl(context),
                                icon: const Icon(Icons.save_outlined),
                                label: Text(strings.saveApiBaseUrl),
                              ),
                              const SizedBox(height: 10),
                              FilledButton.tonalIcon(
                                onPressed: _isApiActionInProgress
                                    ? null
                                    : () => _testApiConnection(context),
                                icon: const Icon(Icons.wifi_tethering_rounded),
                                label: Text(strings.testApiConnection),
                              ),
                              const SizedBox(height: 10),
                              OutlinedButton.icon(
                                onPressed: _isApiActionInProgress
                                    ? null
                                    : () => _resetApiBaseUrl(context),
                                icon: const Icon(Icons.restart_alt_rounded),
                                label: Text(strings.resetApiBaseUrl),
                              ),
                              if (_apiFeedbackMessage != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: _apiFeedbackIsError
                                        ? const Color(0xFFFBE7E5)
                                        : const Color(0xFFE8F1E7),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    _apiFeedbackMessage!,
                                    style: TextStyle(
                                      color: _apiFeedbackIsError
                                          ? Theme.of(context).colorScheme.error
                                          : const Color(0xFF1F5F31),
                                    ),
                                  ),
                                ),
                              ],
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
        },
      ),
    );
  }

  void _syncProfileFields(UserProfile? profile) {
    if (profile == null) {
      return;
    }

    final signature = [
      profile.displayName,
      profile.firstName,
      profile.lastName,
      profile.bio ?? '',
    ].join('|');

    if (_lastSyncedProfileSignature == signature) {
      return;
    }

    _displayNameController.text = profile.displayName;
    _firstNameController.text = profile.firstName;
    _lastNameController.text = profile.lastName;
    _bioController.text = profile.bio ?? '';
    _lastSyncedProfileSignature = signature;
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

    _lastSyncedApiBaseUrl =
        context.read<ApiBaseUrlProvider>().currentApiBaseUrl;
    _apiBaseUrlController.text = _lastSyncedApiBaseUrl!;

    _showSnackBar(
      context,
      '${context.strings.apiBaseUrlSaved}\n${_lastSyncedApiBaseUrl!}',
      isError: false,
    );
  }

  Future<void> _resetApiBaseUrl(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final apiBaseUrlProvider = context.read<ApiBaseUrlProvider>();
    final apiHealthService = context.read<ApiHealthService>();
    final strings = context.strings;

    _setApiActionInProgress(true);
    _setApiFeedback(
      strings.apiAutoDetecting,
      isError: false,
    );

    try {
      await apiBaseUrlProvider.resetToDefault();

      if (!mounted) {
        return;
      }

      _lastSyncedApiBaseUrl = '';
      _apiBaseUrlController.clear();

      final isHealthy = await apiHealthService.ping();

      if (!mounted) {
        return;
      }

      final resolvedApiBaseUrl = apiBaseUrlProvider.currentApiBaseUrl.trim();

      _showSnackBar(
        context,
        isHealthy
            ? '${strings.apiBaseUrlReset}\n${strings.apiConnectionSuccess}\n$resolvedApiBaseUrl'
            : '${strings.apiBaseUrlReset}\n${strings.apiConnectionFailure}',
        isError: !isHealthy,
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      _showSnackBar(
        context,
        '${strings.apiBaseUrlReset}\n${error.message}',
        isError: true,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showSnackBar(
        context,
        '${strings.apiBaseUrlReset}\n${strings.apiConnectionFailure}',
        isError: true,
      );
    } finally {
      _setApiActionInProgress(false);
    }
  }

  Future<void> _testApiConnection(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final apiBaseUrlProvider = context.read<ApiBaseUrlProvider>();
    final manualApiBaseUrl = _apiBaseUrlController.text.trim();
    final strings = context.strings;

    _setApiActionInProgress(true);
    _setApiFeedback(
      strings.apiTestingConnection,
      isError: false,
    );

    try {
      if (manualApiBaseUrl.isNotEmpty) {
        if (!_apiBaseUrlFormKey.currentState!.validate()) {
          return;
        }

        await apiBaseUrlProvider.setApiBaseUrl(manualApiBaseUrl);
      } else if (!apiBaseUrlProvider.hasManualOverride) {
        await apiBaseUrlProvider.refreshAutoDetectedUrl();
      }

      if (!mounted) {
        return;
      }

      final isHealthy = await context.read<ApiHealthService>().ping();

      if (!mounted) {
        return;
      }

      final resolvedApiBaseUrl =
          context.read<ApiBaseUrlProvider>().currentApiBaseUrl.trim();

      _showSnackBar(
        context,
        isHealthy
            ? '${strings.apiConnectionSuccess}\n$resolvedApiBaseUrl'
            : strings.apiConnectionFailure,
        isError: !isHealthy,
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      _showSnackBar(
        context,
        error.message,
        isError: true,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showSnackBar(
        context,
        strings.apiConnectionFailure,
        isError: true,
      );
    } finally {
      _setApiActionInProgress(false);
    }
  }

  void _setApiActionInProgress(bool value) {
    if (!mounted || _isApiActionInProgress == value) {
      return;
    }

    setState(() {
      _isApiActionInProgress = value;
    });
  }

  void _setApiFeedback(
    String message, {
    required bool isError,
  }) {
    if (!mounted) {
      return;
    }

    setState(() {
      _apiFeedbackMessage = message;
      _apiFeedbackIsError = isError;
    });
  }

  void _showSnackBar(
    BuildContext context,
    String message, {
    required bool isError,
  }) {
    _setApiFeedback(
      message,
      isError: isError,
    );

    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
      ),
    );
  }

  Future<void> _saveProfile(BuildContext context) async {
    if (!_profileFormKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final success = await context.read<ProfileController>().updateProfile(
          UpdateMyProfileInput(
            displayName: _displayNameController.text.trim(),
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            bio: _bioController.text.trim(),
          ),
        );

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.strings.profileSaved),
        ),
      );
    }
  }
}
