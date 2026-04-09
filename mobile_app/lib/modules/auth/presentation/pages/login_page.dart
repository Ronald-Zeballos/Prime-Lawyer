import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/config/app_config.dart';
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
    final appConfig = context.read<AppConfig>();
    final authController = context.watch<AuthController>();

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
                  Text(
                    'Prime Lawyer',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Sign in to continue with the legal MVP demo.',
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
                              'Demo credentials',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'You can keep the default admin user for the MVP demo.',
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.username],
                              decoration: const InputDecoration(
                                labelText: 'Email',
                              ),
                              onChanged: (_) {
                                context.read<AuthController>().clearError();
                              },
                              validator: (value) {
                                final normalizedValue = value?.trim() ?? '';

                                if (normalizedValue.isEmpty) {
                                  return 'Email is required.';
                                }

                                if (!normalizedValue.contains('@')) {
                                  return 'Email format looks invalid.';
                                }

                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              autofillHints: const [AutofillHints.password],
                              decoration: const InputDecoration(
                                labelText: 'Password',
                              ),
                              onChanged: (_) {
                                context.read<AuthController>().clearError();
                              },
                              validator: (value) {
                                if ((value ?? '').isEmpty) {
                                  return 'Password is required.';
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
                                    ? 'Signing in...'
                                    : 'Sign in',
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
                      'API base URL\n${appConfig.apiBaseUrl}',
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
