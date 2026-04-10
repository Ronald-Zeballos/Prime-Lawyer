import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../shared/localization/app_strings_context.dart';
import '../../../documents/domain/entities/document.dart';
import '../../domain/entities/document_analysis_match.dart';
import '../../domain/usecases/get_document_analysis_preview_use_case.dart';
import '../controllers/document_analysis_controller.dart';

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
                child: Text(
                  controller.errorMessage!,
                  textAlign: TextAlign.center,
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

          return ListView(
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
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      document.originalName,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      analysis.summary,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
                    Text(analysis.sourceCaseSubject),
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
                              child: _MatchCard(match: match),
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

class _MatchCard extends StatelessWidget {
  const _MatchCard({
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
            match.subject,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 6),
          Text(match.processType),
          const SizedBox(height: 6),
          Text(strings.caseStatus(match.status)),
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
