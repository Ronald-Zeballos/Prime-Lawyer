import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../shared/localization/app_strings_context.dart';
import '../../../documents/domain/entities/document.dart';
import '../../../documents/presentation/pages/documents_page.dart';
import '../../domain/entities/document_analysis_document_match.dart';
import '../../domain/entities/document_analysis_match.dart';
import '../../domain/usecases/get_document_analysis_preview_use_case.dart';
import '../controllers/document_analysis_controller.dart';
import 'contextual_legal_consultation_page.dart';

class DocumentAnalysisPage extends StatelessWidget {
  const DocumentAnalysisPage({
    super.key,
    required this.document,
  });

  final Document document;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DocumentAnalysisController>(
      create: (context) => DocumentAnalysisController(
        documentId: document.id,
        getDocumentAnalysisPreviewUseCase:
            context.read<GetDocumentAnalysisPreviewUseCase>(),
      )..load(),
      child: _DocumentAnalysisView(document: document),
    );
  }
}

class _DocumentAnalysisView extends StatelessWidget {
  const _DocumentAnalysisView({
    required this.document,
  });

  final Document document;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DocumentAnalysisController>();
    final strings = context.strings;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.analysisPreviewTitle),
        actions: [
          IconButton(
            onPressed: controller.isLoading ? null : controller.refresh,
            tooltip: strings.refreshAnalysisAction,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      bottomNavigationBar:
          controller.analysis == null || controller.errorMessage != null
              ? null
              : SafeArea(
                  minimum: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        AppRoutes.legalAiConsultation,
                        arguments: ContextualLegalConsultationPageArgs(
                          preselectedCaseFileId: document.caseFileId,
                          preselectedDocumentId: document.id,
                        ),
                      );
                    },
                    icon: const Icon(Icons.auto_awesome_rounded),
                    label: Text(strings.askAiAboutDocument),
                  ),
                ),
      body: Builder(
        builder: (context) {
          if (controller.isLoading && controller.analysis == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      controller.errorMessage!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: controller.refresh,
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(strings.refreshAnalysisAction),
                    ),
                  ],
                ),
              ),
            );
          }

          final analysis = controller.analysis;

          if (analysis == null) {
            return Center(
              child: Text(strings.analysisUnavailable),
            );
          }

          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF223447),
                          Color(0xFF36597B),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            strings.analysisPreviewBadge,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          document.originalName,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          analysis.summary,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.92),
                                  ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _HeroChip(label: analysis.sourceCaseInternalCode),
                            _HeroChip(label: analysis.sourceProcessType),
                            _HeroChip(
                              label: strings.ocrStatus(
                                analysis.sourceDocumentOcrStatus,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _InfoSectionCard(
                    title: strings.analysisSummaryTitle,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(analysis.sourceCaseTitle),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _NeutralChip(
                              label: strings.caseStatus(analysis.sourceStatus),
                            ),
                            _NeutralChip(
                              label: strings.confidentialityLevel(
                                analysis.sourceConfidentialityLevel,
                              ),
                            ),
                            _NeutralChip(label: analysis.sourceDocumentType),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _InfoSectionCard(
                    title: strings.analysisSourceDocumentTitle,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          analysis.sourceDocumentName,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _NeutralChip(
                              label: strings.ocrStatus(
                                analysis.sourceDocumentOcrStatus,
                              ),
                            ),
                            _NeutralChip(label: analysis.sourceUploadSource),
                            _NeutralChip(label: analysis.sourceDocumentType),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _BulletSectionCard(
                    title: strings.analysisHighlightsTitle,
                    items: analysis.highlights,
                  ),
                  const SizedBox(height: 16),
                  _BulletSectionCard(
                    title: strings.analysisNextStepsTitle,
                    items: analysis.recommendedNextSteps,
                  ),
                  const SizedBox(height: 16),
                  _BulletSectionCard(
                    title: strings.analysisLimitationsTitle,
                    items: analysis.limitations,
                  ),
                  const SizedBox(height: 16),
                  _InfoSectionCard(
                    title: strings.analysisMatchesTitle,
                    child: analysis.hasMatches
                        ? Column(
                            children: [
                              for (final match in analysis.matches)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _CaseMatchCard(match: match),
                                ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                strings.analysisNoMatchesTitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 6),
                              Text(strings.analysisNoMatchesDescription),
                            ],
                          ),
                  ),
                  const SizedBox(height: 16),
                  _InfoSectionCard(
                    title: strings.analysisDocumentMatchesTitle,
                    child: analysis.hasDocumentMatches
                        ? Column(
                            children: [
                              for (final match in analysis.documentMatches)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _DocumentMatchCard(match: match),
                                ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                strings.analysisNoDocumentMatchesTitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                  strings.analysisNoDocumentMatchesDescription),
                            ],
                          ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
              if (controller.isLoading)
                const Align(
                  alignment: Alignment.topCenter,
                  child: LinearProgressIndicator(),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _NeutralChip extends StatelessWidget {
  const _NeutralChip({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E7DA),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label),
    );
  }
}

class _InfoSectionCard extends StatelessWidget {
  const _InfoSectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _BulletSectionCard extends StatelessWidget {
  const _BulletSectionCard({
    required this.title,
    required this.items,
  });

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return _InfoSectionCard(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 7),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(item)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CaseMatchCard extends StatelessWidget {
  const _CaseMatchCard({
    required this.match,
  });

  final DocumentAnalysisMatch match;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F4EC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  match.internalCode,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              _NeutralChip(label: 'Score ${match.score}'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            match.title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _NeutralChip(label: match.processType),
              _NeutralChip(label: strings.caseStatus(match.status)),
              _NeutralChip(label: strings.caseVisibility(match.visibility)),
              _NeutralChip(
                label: strings.knowledgeStatus(match.knowledgeStatus),
              ),
            ],
          ),
          if ((match.snippet ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(match.snippet!),
          ],
          const SizedBox(height: 10),
          Text(strings
              .analysisMatchedDocumentsCount(match.matchedDocumentCount)),
          const SizedBox(height: 12),
          for (final reason in match.matchReasons)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.subdirectory_arrow_right_rounded,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(child: Text(reason)),
                ],
              ),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed(
                AppRoutes.caseFileDetail,
                arguments: match.caseFileId,
              );
            },
            icon: const Icon(Icons.open_in_new_rounded),
            label: Text(strings.analysisOpenCaseAction),
          ),
        ],
      ),
    );
  }
}

class _DocumentMatchCard extends StatelessWidget {
  const _DocumentMatchCard({
    required this.match,
  });

  final DocumentAnalysisDocumentMatch match;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F4EC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  match.originalName,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              _NeutralChip(label: 'Score ${match.score}'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${match.caseInternalCode} · ${match.caseTitle}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _NeutralChip(label: match.processType),
              _NeutralChip(label: strings.caseStatus(match.status)),
              _NeutralChip(label: strings.ocrStatus(match.ocrStatus)),
              _NeutralChip(label: match.fileType),
            ],
          ),
          if ((match.snippet ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(match.snippet!),
          ],
          const SizedBox(height: 12),
          for (final reason in match.matchReasons)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.subdirectory_arrow_right_rounded,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(child: Text(reason)),
                ],
              ),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed(
                AppRoutes.documents,
                arguments: DocumentsPageArgs(
                  caseFileId: match.caseFileId,
                  caseFileTitle:
                      '${match.caseInternalCode} · ${match.caseTitle}',
                ),
              );
            },
            icon: const Icon(Icons.description_outlined),
            label: Text(strings.analysisOpenDocumentsAction),
          ),
        ],
      ),
    );
  }
}
