import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/network/api_client.dart';
import '../core/storage/app_preferences_storage.dart';
import '../core/storage/secure_app_preferences_storage.dart';
import '../core/services/session_service.dart';
import '../core/storage/secure_token_storage.dart';
import '../core/storage/token_storage.dart';
import '../core/widgets/app_loading_view.dart';
import '../modules/auth/data/datasources/auth_remote_data_source.dart';
import '../modules/auth/data/repositories/auth_repository_impl.dart';
import '../modules/auth/domain/repositories/auth_repository.dart';
import '../modules/auth/domain/usecases/sign_in_use_case.dart';
import '../modules/auth/presentation/pages/login_page.dart';
import '../modules/case_files/data/datasources/case_files_remote_data_source.dart';
import '../modules/case_files/data/repositories/case_file_repository_impl.dart';
import '../modules/case_files/domain/repositories/case_file_repository.dart';
import '../modules/case_files/domain/usecases/create_case_file_use_case.dart';
import '../modules/case_files/domain/usecases/get_case_file_detail_use_case.dart';
import '../modules/case_files/domain/usecases/get_case_files_use_case.dart';
import '../modules/document_capture/data/repositories/file_picker_document_capture_repository.dart';
import '../modules/document_capture/domain/repositories/document_capture_repository.dart';
import '../modules/document_capture/domain/usecases/pick_document_use_case.dart';
import '../modules/clients/data/datasources/clients_remote_data_source.dart';
import '../modules/clients/data/repositories/client_repository_impl.dart';
import '../modules/clients/domain/repositories/client_repository.dart';
import '../modules/clients/domain/usecases/create_client_use_case.dart';
import '../modules/clients/domain/usecases/get_clients_use_case.dart';
import '../modules/documents/data/datasources/documents_remote_data_source.dart';
import '../modules/documents/data/repositories/document_repository_impl.dart';
import '../modules/documents/domain/repositories/document_repository.dart';
import '../modules/documents/domain/usecases/get_case_documents_use_case.dart';
import '../modules/documents/domain/usecases/register_document_use_case.dart';
import '../modules/home/domain/usecases/get_home_dashboard_use_case.dart';
import '../modules/home/presentation/pages/home_page.dart';
import '../shared/providers/app_language_provider.dart';
import '../shared/providers/session_provider.dart';
import 'config/app_config.dart';
import 'routes/app_router.dart';
import 'theme/app_theme.dart';

class PrimeLawyerApp extends StatelessWidget {
  const PrimeLawyerApp({
    super.key,
    required this.appConfig,
  });

  final AppConfig appConfig;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppConfig>.value(value: appConfig),
        Provider<TokenStorage>(
          create: (_) => SecureTokenStorage(),
        ),
        Provider<AppPreferencesStorage>(
          create: (_) => SecureAppPreferencesStorage(),
        ),
        Provider<SessionService>(
          create: (context) => SessionService(
            tokenStorage: context.read<TokenStorage>(),
          ),
        ),
        Provider<ApiClient>(
          create: (context) => ApiClient(
            baseUrl: context.read<AppConfig>().apiBaseUrl,
            tokenStorage: context.read<TokenStorage>(),
          ),
        ),
        Provider<AuthRemoteDataSource>(
          create: (context) => AuthRemoteDataSource(
            context.read<ApiClient>(),
          ),
        ),
        Provider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(
            context.read<AuthRemoteDataSource>(),
          ),
        ),
        Provider<SignInUseCase>(
          create: (context) => SignInUseCase(
            context.read<AuthRepository>(),
          ),
        ),
        Provider<ClientsRemoteDataSource>(
          create: (context) => ClientsRemoteDataSource(
            context.read<ApiClient>(),
          ),
        ),
        Provider<ClientRepository>(
          create: (context) => ClientRepositoryImpl(
            context.read<ClientsRemoteDataSource>(),
          ),
        ),
        Provider<GetClientsUseCase>(
          create: (context) => GetClientsUseCase(
            context.read<ClientRepository>(),
          ),
        ),
        Provider<CreateClientUseCase>(
          create: (context) => CreateClientUseCase(
            context.read<ClientRepository>(),
          ),
        ),
        Provider<CaseFilesRemoteDataSource>(
          create: (context) => CaseFilesRemoteDataSource(
            context.read<ApiClient>(),
          ),
        ),
        Provider<CaseFileRepository>(
          create: (context) => CaseFileRepositoryImpl(
            context.read<CaseFilesRemoteDataSource>(),
          ),
        ),
        Provider<GetCaseFilesUseCase>(
          create: (context) => GetCaseFilesUseCase(
            context.read<CaseFileRepository>(),
          ),
        ),
        Provider<CreateCaseFileUseCase>(
          create: (context) => CreateCaseFileUseCase(
            context.read<CaseFileRepository>(),
          ),
        ),
        Provider<GetCaseFileDetailUseCase>(
          create: (context) => GetCaseFileDetailUseCase(
            context.read<CaseFileRepository>(),
          ),
        ),
        Provider<GetHomeDashboardUseCase>(
          create: (context) => GetHomeDashboardUseCase(
            clientRepository: context.read<ClientRepository>(),
            caseFileRepository: context.read<CaseFileRepository>(),
          ),
        ),
        Provider<DocumentCaptureRepository>(
          create: (_) => const FilePickerDocumentCaptureRepository(),
        ),
        Provider<PickDocumentUseCase>(
          create: (context) => PickDocumentUseCase(
            context.read<DocumentCaptureRepository>(),
          ),
        ),
        Provider<DocumentsRemoteDataSource>(
          create: (context) => DocumentsRemoteDataSource(
            context.read<ApiClient>(),
          ),
        ),
        Provider<DocumentRepository>(
          create: (context) => DocumentRepositoryImpl(
            context.read<DocumentsRemoteDataSource>(),
          ),
        ),
        Provider<GetCaseDocumentsUseCase>(
          create: (context) => GetCaseDocumentsUseCase(
            context.read<DocumentRepository>(),
          ),
        ),
        Provider<RegisterDocumentUseCase>(
          create: (context) => RegisterDocumentUseCase(
            context.read<DocumentRepository>(),
          ),
        ),
        ChangeNotifierProvider<SessionProvider>(
          create: (context) => SessionProvider(
            sessionService: context.read<SessionService>(),
          )..bootstrap(),
        ),
        ChangeNotifierProvider<AppLanguageProvider>(
          create: (context) => AppLanguageProvider(
            preferencesStorage: context.read<AppPreferencesStorage>(),
          )..bootstrap(),
        ),
      ],
      child: MaterialApp(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: const _AppEntryPoint(),
      ),
    );
  }
}

class _AppEntryPoint extends StatelessWidget {
  const _AppEntryPoint();

  @override
  Widget build(BuildContext context) {
    final sessionProvider = context.watch<SessionProvider>();

    switch (sessionProvider.status) {
      case SessionStatus.initializing:
        return const AppLoadingView(
          message: 'Preparing Prime Lawyer...',
        );
      case SessionStatus.authenticated:
        return const HomePage();
      case SessionStatus.unauthenticated:
        return const LoginPage();
    }
  }
}
