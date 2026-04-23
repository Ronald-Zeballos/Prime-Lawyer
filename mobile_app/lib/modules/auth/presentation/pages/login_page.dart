import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../shared/localization/app_strings_context.dart';
import '../../../../shared/providers/api_base_url_provider.dart';
import '../../../../shared/providers/session_provider.dart';
import '../../domain/usecases/sign_in_use_case.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthController>(
      create: (context) => AuthController(
        signInUseCase: context.read<SignInUseCase>(),
        sessionProvider: context.read<SessionProvider>(),
      ),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'admin@demo.com');
  final _passwordController = TextEditingController(text: 'Admin123*');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final apiBaseUrlProvider = context.watch<ApiBaseUrlProvider>();
    final strings = context.strings;
    final resolvedApiBaseUrl = apiBaseUrlProvider.currentApiBaseUrl.trim();
    final apiBaseUrlLabel =
        resolvedApiBaseUrl.isEmpty ? 'No URL' : resolvedApiBaseUrl;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRoutes.profile);
                      },
                      tooltip: strings.openSettings,
                      icon: const Icon(Icons.settings_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    strings.appName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    strings.signInSubtitle,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              strings.demoCredentialsTitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              strings.demoCredentialsDescription,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.username],
                              decoration: InputDecoration(
                                labelText: strings.emailLabel,
                              ),
                              onChanged: (_) {
                                context.read<AuthController>().clearError();
                              },
                              validator: (value) {
                                final normalizedValue = value?.trim() ?? '';

                                if (normalizedValue.isEmpty) {
                                  return strings.emailRequiredError;
                                }

                                if (!normalizedValue.contains('@')) {
                                  return strings.emailInvalidError;
                                }

                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              autofillHints: const [AutofillHints.password],
                              decoration: InputDecoration(
                                labelText: strings.passwordLabel,
                              ),
                              onChanged: (_) {
                                context.read<AuthController>().clearError();
                              },
                              validator: (value) {
                                if ((value ?? '').isEmpty) {
                                  return strings.passwordRequiredError;
                                }

                                return null;
                              },
                              onFieldSubmitted: (_) => _submit(context),
                            ),
                            if (authController.errorMessage != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFBE7E5),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  authController.errorMessage!,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),
                            FilledButton(
                              onPressed: authController.isSubmitting
                                  ? null
                                  : () => _submit(context),
                              child: Text(
                                authController.isSubmitting
                                    ? strings.signingIn
                                    : strings.signIn,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E1D7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${strings.apiBaseUrlLabel}\n$apiBaseUrlLabel',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    await context.read<AuthController>().signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }
}
