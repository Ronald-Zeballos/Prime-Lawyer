import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../shared/localization/app_strings_context.dart';
import '../../domain/usecases/create_case_file_use_case.dart';
import '../../domain/usecases/get_case_files_use_case.dart';
import '../controllers/case_files_controller.dart';
import '../widgets/case_file_list_item.dart';
import '../widgets/create_case_file_sheet.dart';

class CaseFilesPage extends StatelessWidget {
  const CaseFilesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CaseFilesController>(
      create: (context) => CaseFilesController(
        getCaseFilesUseCase: context.read<GetCaseFilesUseCase>(),
        createCaseFileUseCase: context.read<CreateCaseFileUseCase>(),
      )..loadInitialData(),
      child: const _CaseFilesView(),
    );
  }
}

class _CaseFilesView extends StatelessWidget {
  const _CaseFilesView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CaseFilesController>();
    final strings = context.strings;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.caseFilesTitle),
        actions: [
          IconButton(
            onPressed: controller.isLoading ? null : controller.refresh,
            tooltip: strings.refreshCaseFiles,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateCaseFileSheet(context),
        icon: const Icon(Icons.create_new_folder_outlined),
        label: Text(strings.newCaseFile),
      ),
      body: Column(
        children: [
          if (controller.errorMessage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBE7E5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  controller.errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (controller.isLoading && !controller.hasCaseFiles) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!controller.hasCaseFiles) {
                  return RefreshIndicator(
                    onRefresh: controller.refresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      children: [
                        const SizedBox(height: 80),
                        Icon(
                          Icons.folder_open_outlined,
                          size: 56,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          strings.noCaseFilesListTitle,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          strings.noCaseFilesListDescription,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.refresh,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    itemCount: controller.caseFiles.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final caseFile = controller.caseFiles[index];

                      return CaseFileListItem(
                        caseFile: caseFile,
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            AppRoutes.caseFileDetail,
                            arguments: caseFile.id,
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openCreateCaseFileSheet(BuildContext context) {
    final controller = context.read<CaseFilesController>();
    controller.clearError();

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ChangeNotifierProvider<CaseFilesController>.value(
        value: controller,
        child: Consumer<CaseFilesController>(
          builder: (context, value, _) => CreateCaseFileSheet(
            isSubmitting: value.isSubmitting,
            errorMessage: value.errorMessage,
            onSubmit: value.createCaseFile,
          ),
        ),
      ),
    );
  }
}
