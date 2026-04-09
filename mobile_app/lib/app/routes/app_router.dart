import 'package:flutter/material.dart';

import '../../modules/auth/presentation/pages/login_page.dart';
import '../../modules/case_files/presentation/pages/case_file_detail_page.dart';
import '../../modules/case_files/presentation/pages/case_files_page.dart';
import '../../modules/clients/presentation/pages/clients_page.dart';
import '../../modules/documents/presentation/pages/documents_page.dart';
import '../../modules/home/presentation/pages/home_page.dart';
import 'app_routes.dart';

class AppRouter {
  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute<void>(
          builder: (_) => const LoginPage(),
          settings: settings,
        );
      case AppRoutes.home:
        return MaterialPageRoute<void>(
          builder: (_) => const HomePage(),
          settings: settings,
        );
      case AppRoutes.clients:
        return MaterialPageRoute<void>(
          builder: (_) => const ClientsPage(),
          settings: settings,
        );
      case AppRoutes.caseFiles:
        return MaterialPageRoute<void>(
          builder: (_) => const CaseFilesPage(),
          settings: settings,
        );
      case AppRoutes.caseFileDetail:
        final caseFileId = settings.arguments;

        if (caseFileId is! String || caseFileId.isEmpty) {
          return MaterialPageRoute<void>(
            builder: (_) => const _UnknownRoutePage(
              routeName: AppRoutes.caseFileDetail,
            ),
            settings: settings,
          );
        }

        return MaterialPageRoute<void>(
          builder: (_) => CaseFileDetailPage(caseFileId: caseFileId),
          settings: settings,
        );
      case AppRoutes.documents:
        final arguments = settings.arguments;

        if (arguments is! DocumentsPageArgs) {
          return MaterialPageRoute<void>(
            builder: (_) => const _UnknownRoutePage(
              routeName: AppRoutes.documents,
            ),
            settings: settings,
          );
        }

        return MaterialPageRoute<void>(
          builder: (_) => DocumentsPage(args: arguments),
          settings: settings,
        );
      default:
        return MaterialPageRoute<void>(
          builder: (_) => _UnknownRoutePage(routeName: settings.name),
          settings: settings,
        );
    }
  }
}

class _UnknownRoutePage extends StatelessWidget {
  const _UnknownRoutePage({
    this.routeName,
  });

  final String? routeName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route not found'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'The route "${routeName ?? 'unknown'}" is not registered yet.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
