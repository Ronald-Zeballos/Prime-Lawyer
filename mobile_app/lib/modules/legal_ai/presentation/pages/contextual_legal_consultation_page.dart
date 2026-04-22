import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../shared/localization/app_strings_context.dart';
import '../../../case_files/domain/entities/case_file.dart';
import '../../../case_files/domain/usecases/get_case_files_use_case.dart';
import '../../../documents/domain/entities/document.dart';
import '../../../documents/presentation/pages/documents_page.dart';
import '../../../documents/domain/usecases/get_case_documents_use_case.dart';
import '../../domain/entities/contextual_legal_answer.dart';
import '../../domain/usecases/ask_contextual_legal_question_use_case.dart';
import '../controllers/contextual_legal_consultation_controller.dart';

class ContextualLegalConsultationPageArgs {
  const ContextualLegalConsultationPageArgs({
    this.preselectedCaseFileId,
    this.preselectedDocumentId,
    this.initialQuestion,
  });

  final String? preselectedCaseFileId;
  final String? preselectedDocumentId;
  final String? initialQuestion;
}

class ContextualLegalConsultationPage extends StatelessWidget {
  const ContextualLegalConsultationPage({
    super.key,
    required this.args,
  });

  final ContextualLegalConsultationPageArgs args;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ContextualLegalConsultationController>(
      create: (context) => ContextualLegalConsultationController(
        getCaseFilesUseCase: context.read<GetCaseFilesUseCase>(),
        getCaseDocumentsUseCase: context.read<GetCaseDocumentsUseCase>(),
        askContextualLegalQuestionUseCase:
            context.read<AskContextualLegalQuestionUseCase>(),
        initialCaseFileId: args.preselectedCaseFileId,
        initialDocumentId: args.preselectedDocumentId,
      )..bootstrap(),
      child: _ContextualLegalConsultationView(args: args),
    );
  }
}

class _ContextualLegalConsultationView extends StatefulWidget {
  const _ContextualLegalConsultationView({
    required this.args,
  });

  final ContextualLegalConsultationPageArgs args;

  @override
  State<_ContextualLegalConsultationView> createState() =>
      _ContextualLegalConsultationViewState();
}

class _ContextualLegalConsultationViewState
    extends State<_ContextualLegalConsultationView> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  late final TextEditingController _questionController;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(
      text: widget.args.initialQuestion ?? '',
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ContextualLegalConsultationController>();
    final strings = context.strings;
    final selectedCaseFile = controller.selectedCaseFile;
    final selectedDocument = controller.selectedDocument;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.legalAiConsultationTitle),
      ),
      body: Builder(
        builder: (context) {
          if (controller.isBootstrapping && controller.caseFiles.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            children: [
              _HeroSection(
                title: strings.legalAiConsultationTitle,
                subtitle: strings.legalAiConsultationSubtitle,
                selectedCaseFile: selectedCaseFile,
                selectedDocument: selectedDocument,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.legalAiQuestionCardTitle,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(strings.legalAiQuestionCardDescription),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String?>(
                          key: ValueKey(controller.selectedCaseFileId),
                          initialValue: controller.selectedCaseFileId,
                          decoration: InputDecoration(
                            labelText: strings.aiCaseContextLabel,
                          ),
                          items: [
                            DropdownMenuItem<String?>(
                              value: null,
                              child: Text(strings.aiNoSpecificCase),
                            ),
                            for (final caseFile in controller.caseFiles)
                              DropdownMenuItem<String?>(
                                value: caseFile.id,
                                child: Text(caseFile.displayLabel),
                              ),
                          ],
                          onChanged: (value) {
                            controller.selectCaseFile(value);
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String?>(
                          key: ValueKey(
                            '${controller.selectedCaseFileId}:${controller.selectedDocumentId}:${controller.documents.length}',
                          ),
                          initialValue: controller.selectedDocumentId,
                          decoration: InputDecoration(
                            labelText: strings.aiDocumentContextLabel,
                            helperText: selectedCaseFile == null
                                ? strings.aiSelectCaseFirstHint
                                : controller.isLoadingDocuments
                                    ? strings.aiLoadingDocuments
                                    : controller.hasDocuments
                                        ? strings.aiDocumentContextHelper
                                        : strings.aiNoDocumentsForSelectedCase,
                          ),
                          items: [
                            DropdownMenuItem<String?>(
                              value: null,
                              child: Text(strings.aiNoSpecificDocument),
                            ),
                            for (final document in controller.documents)
                              DropdownMenuItem<String?>(
                                value: document.id,
                                child: Text(document.originalName),
                              ),
                          ],
                          onChanged: selectedCaseFile == null ||
                                  controller.isLoadingDocuments
                              ? null
                              : (value) {
                                  controller.selectDocument(value);
                                },
                        ),
                        if (selectedCaseFile != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F2EA),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              strings.aiProcessTypeAutoHint(
                                selectedCaseFile.processType,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ActionChip(
                              label: Text(strings.aiSuggestionSummary),
                              onPressed: () {
                                _questionController.text =
                                    strings.aiSuggestionSummaryQuestion;
                              },
                            ),
                            ActionChip(
                              label: Text(strings.aiSuggestionDocuments),
                              onPressed: () {
                                _questionController.text =
                                    strings.aiSuggestionDocumentsQuestion;
                              },
                            ),
                            ActionChip(
                              label: Text(strings.aiSuggestionNextSteps),
                              onPressed: () {
                                _questionController.text =
                                    strings.aiSuggestionNextStepsQuestion;
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _questionController,
                          minLines: 4,
                          maxLines: 6,
                          decoration: InputDecoration(
                            labelText: strings.aiQuestionLabel,
                            hintText: strings.aiQuestionHint,
                          ),
                          onChanged: (_) {
                            controller.clearError();
                          },
                          validator: (value) {
                            if ((value?.trim() ?? '').isEmpty) {
                              return strings.aiQuestionRequiredError;
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: controller.isSubmitting
                              ? null
                              : () => _submit(context),
                          icon: const Icon(Icons.auto_awesome_rounded),
                          label: Text(
                            controller.isSubmitting
                                ? strings.aiSubmittingQuestion
                                : strings.aiSubmitQuestion,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (controller.errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
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
              ],
              if (controller.hasConsultationHistory) ...[
                const SizedBox(height: 16),
                _ConsultationHistorySection(
                  consultations: controller.consultationHistory,
                  currentQueryId: controller.answer?.queryId,
                  onOpenConsultation: (answer) =>
                      _openPreviousConsultation(context, answer),
                ),
              ],
              const SizedBox(height: 16),
              if (!controller.hasAnswer)
                _EmptyAnswerState(
                  title: strings.aiNoAnswerYetTitle,
                  description: strings.aiNoAnswerYetDescription,
                )
              else
                _AnswerSections(
                  answer: controller.answer!,
                  onCopyAnswer: () => _copyAnswer(context, controller.answer!),
                  onStartNewQuestion: () => _startNewQuestion(context),
                  onUseFollowUpQuestion: (question) =>
                      _prepareFollowUpQuestion(question),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    final controller = context.read<ContextualLegalConsultationController>();
    final success = await controller.askQuestion(_questionController.text);

    if (!mounted || !success) {
      return;
    }

    final answer = controller.answer;

    if (answer != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.strings.aiConsultationReady(answer.groundingStatus),
          ),
        ),
      );
    }

    await _scrollToAnswer();
  }

  Future<void> _scrollToAnswer() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));

    if (!_scrollController.hasClients) {
      return;
    }

    await _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _openPreviousConsultation(
    BuildContext context,
    ContextualLegalAnswer answer,
  ) async {
    _questionController
      ..text = answer.question
      ..selection = TextSelection.fromPosition(
        TextPosition(offset: answer.question.length),
      );

    context
        .read<ContextualLegalConsultationController>()
        .showHistoryAnswer(answer.queryId);

    await _scrollToAnswer();
  }

  Future<void> _copyAnswer(
    BuildContext context,
    ContextualLegalAnswer answer,
  ) async {
    await Clipboard.setData(ClipboardData(text: answer.answer));

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.strings.aiAnswerCopied),
      ),
    );
  }

  Future<void> _startNewQuestion(BuildContext context) async {
    context.read<ContextualLegalConsultationController>().clearCurrentAnswer();
    _questionController.clear();

    if (!_scrollController.hasClients) {
      return;
    }

    await _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _prepareFollowUpQuestion(String question) async {
    _questionController
      ..text = question
      ..selection = TextSelection.fromPosition(
        TextPosition(offset: question.length),
      );

    if (!_scrollController.hasClients) {
      return;
    }

    await _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.title,
    required this.subtitle,
    required this.selectedCaseFile,
    required this.selectedDocument,
  });

  final String title;
  final String subtitle;
  final CaseFile? selectedCaseFile;
  final Document? selectedDocument;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final selectedCaseLabel = selectedCaseFile == null
        ? strings.aiNoSpecificCase
        : strings.selectedCaseContextLabel(selectedCaseFile!.internalCode);
    final selectedDocumentLabel = selectedDocument == null
        ? strings.aiNoSpecificDocument
        : strings.selectedDocumentContextLabel(
            selectedDocument!.originalName,
          );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1C2F45),
            Color(0xFF3B5F84),
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              strings.legalAiContextualBadge,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.92),
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeroChip(
                label: selectedCaseLabel,
              ),
              _HeroChip(
                label: selectedDocumentLabel,
              ),
            ],
          ),
        ],
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

class _EmptyAnswerState extends StatelessWidget {
  const _EmptyAnswerState({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.auto_awesome_outlined,
              size: 42,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsultationHistorySection extends StatelessWidget {
  const _ConsultationHistorySection({
    required this.consultations,
    required this.currentQueryId,
    required this.onOpenConsultation,
  });

  final List<ContextualLegalAnswer> consultations;
  final String? currentQueryId;
  final ValueChanged<ContextualLegalAnswer> onOpenConsultation;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.aiConsultationHistoryTitle,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(strings.aiConsultationHistoryDescription),
            const SizedBox(height: 12),
            for (final answer in consultations)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ConsultationHistoryTile(
                  answer: answer,
                  isCurrent: answer.queryId == currentQueryId,
                  onTap: () => onOpenConsultation(answer),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ConsultationHistoryTile extends StatelessWidget {
  const _ConsultationHistoryTile({
    required this.answer,
    required this.isCurrent,
    required this.onTap,
  });

  final ContextualLegalAnswer answer;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isCurrent ? const Color(0xFFE6ECF5) : const Color(0xFFF7F2EA),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    answer.question,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _GroundingChip(status: answer.groundingStatus),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              strings.aiHistoryContextSummary(
                answer.usedContextCases.length,
                answer.usedContextDocuments.length,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              strings.formatDateTime(answer.createdAt),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerSections extends StatelessWidget {
  const _AnswerSections({
    required this.answer,
    required this.onCopyAnswer,
    required this.onStartNewQuestion,
    required this.onUseFollowUpQuestion,
  });

  final ContextualLegalAnswer answer;
  final VoidCallback onCopyAnswer;
  final VoidCallback onStartNewQuestion;
  final ValueChanged<String> onUseFollowUpQuestion;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        strings.aiResponseTitle,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    _GroundingChip(status: answer.groundingStatus),
                  ],
                ),
                const SizedBox(height: 12),
                Text(answer.answer),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F2EA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(answer.disclaimer),
                ),
                const SizedBox(height: 12),
                Text(
                  strings.aiQueryIdLabel(answer.queryId),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                Text(
                  strings.aiQuestionAskedLabel,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(answer.question),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    OutlinedButton.icon(
                      onPressed: onCopyAnswer,
                      icon: const Icon(Icons.content_copy_rounded),
                      label: Text(strings.aiCopyAnswerAction),
                    ),
                    OutlinedButton.icon(
                      onPressed: onStartNewQuestion,
                      icon: const Icon(Icons.edit_note_rounded),
                      label: Text(strings.aiNewQuestionAction),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (answer.sourceCaseFile != null)
          _SourceCaseCard(sourceCaseFile: answer.sourceCaseFile!),
        if (answer.sourceCaseFile != null) const SizedBox(height: 16),
        if (answer.sourceDocument != null)
          _SourceDocumentCard(sourceDocument: answer.sourceDocument!),
        if (answer.sourceDocument != null) const SizedBox(height: 16),
        _BulletSectionCard(
          title: strings.aiRecommendedNextStepsTitle,
          items: answer.recommendedNextSteps,
        ),
        const SizedBox(height: 16),
        _FollowUpQuestionsCard(
          title: strings.aiFollowUpSuggestionsTitle,
          questions: answer.followUpQuestions,
          onUseQuestion: onUseFollowUpQuestion,
        ),
        const SizedBox(height: 16),
        _BulletSectionCard(
          title: strings.aiLimitationsTitle,
          items: answer.limitations,
        ),
        const SizedBox(height: 16),
        _ContextCasesSection(cases: answer.usedContextCases),
        const SizedBox(height: 16),
        _ContextDocumentsSection(documents: answer.usedContextDocuments),
      ],
    );
  }
}

class _GroundingChip extends StatelessWidget {
  const _GroundingChip({
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = switch (status) {
      'GROUNDED' => (
          background: const Color(0xFFE3F2E7),
          foreground: const Color(0xFF1F6A3A),
        ),
      'PARTIAL' => (
          background: const Color(0xFFFFF1D6),
          foreground: const Color(0xFF8B5A00),
        ),
      _ => (
          background: const Color(0xFFFBE7E5),
          foreground: const Color(0xFF9D3B32),
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        strings.aiGroundingStatus(status),
        style: TextStyle(
          color: palette.foreground,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _SourceCaseCard extends StatelessWidget {
  const _SourceCaseCard({
    required this.sourceCaseFile,
  });

  final LegalAiSourceCaseFile sourceCaseFile;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.aiSourceCaseTitle,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(
              sourceCaseFile.displayLabel,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            if ((sourceCaseFile.descriptionSnippet ?? '').isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(sourceCaseFile.descriptionSnippet!),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _NeutralChip(label: strings.caseStatus(sourceCaseFile.status)),
                _NeutralChip(label: sourceCaseFile.processType),
                _NeutralChip(
                  label: strings.caseVisibility(sourceCaseFile.visibility),
                ),
                _NeutralChip(
                  label:
                      strings.knowledgeStatus(sourceCaseFile.knowledgeStatus),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceDocumentCard extends StatelessWidget {
  const _SourceDocumentCard({
    required this.sourceDocument,
  });

  final LegalAiSourceDocument sourceDocument;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.aiSourceDocumentTitle,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(
              sourceDocument.originalName,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _NeutralChip(label: sourceDocument.fileType),
                _NeutralChip(
                  label: strings.ocrStatus(sourceDocument.ocrStatus),
                ),
                _NeutralChip(label: sourceDocument.uploadSource),
              ],
            ),
            if ((sourceDocument.snippet ?? '').isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(sourceDocument.snippet!),
            ],
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FollowUpQuestionsCard extends StatelessWidget {
  const _FollowUpQuestionsCard({
    required this.title,
    required this.questions,
    required this.onUseQuestion,
  });

  final String title;
  final List<String> questions;
  final ValueChanged<String> onUseQuestion;

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final question in questions)
                  ActionChip(
                    label: Text(question),
                    onPressed: () => onUseQuestion(question),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ContextCasesSection extends StatelessWidget {
  const _ContextCasesSection({
    required this.cases,
  });

  final List<LegalAiContextCase> cases;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.aiUsedCasesTitle,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            if (cases.isEmpty)
              Text(strings.aiNoContextCases)
            else
              Column(
                children: [
                  for (final item in cases)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ContextCaseCard(item: item),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ContextDocumentsSection extends StatelessWidget {
  const _ContextDocumentsSection({
    required this.documents,
  });

  final List<LegalAiContextDocument> documents;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.aiUsedDocumentsTitle,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            if (documents.isEmpty)
              Text(strings.aiNoContextDocuments)
            else
              Column(
                children: [
                  for (final item in documents)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ContextDocumentCard(item: item),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ContextCaseCard extends StatelessWidget {
  const _ContextCaseCard({
    required this.item,
  });

  final LegalAiContextCase item;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2EA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.displayLabel,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(strings.aiContextRelation(item.relation)),
                  ],
                ),
              ),
              _ScoreChip(score: item.score),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _NeutralChip(label: item.processType),
              _NeutralChip(label: strings.caseStatus(item.status)),
              _NeutralChip(
                label: strings.caseVisibility(item.visibility),
              ),
            ],
          ),
          if ((item.snippet ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(item.snippet!),
          ],
          if (item.matchReasons.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (final reason in item.matchReasons)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('• $reason'),
              ),
          ],
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed(
                AppRoutes.caseFileDetail,
                arguments: item.caseFileId,
              );
            },
            icon: const Icon(Icons.open_in_new_rounded),
            label: Text(strings.aiOpenCaseAction),
          ),
        ],
      ),
    );
  }
}

class _ContextDocumentCard extends StatelessWidget {
  const _ContextDocumentCard({
    required this.item,
  });

  final LegalAiContextDocument item;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2EA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.originalName,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(item.caseDisplayLabel),
                    const SizedBox(height: 4),
                    Text(strings.aiContextRelation(item.relation)),
                  ],
                ),
              ),
              _ScoreChip(score: item.score),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _NeutralChip(label: item.fileType),
              _NeutralChip(label: strings.ocrStatus(item.ocrStatus)),
              _NeutralChip(label: item.processType),
            ],
          ),
          if ((item.snippet ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(item.snippet!),
          ],
          if (item.matchReasons.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (final reason in item.matchReasons)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('• $reason'),
              ),
          ],
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed(
                AppRoutes.documents,
                arguments: DocumentsPageArgs(
                  caseFileId: item.caseFileId,
                  caseFileTitle: item.caseDisplayLabel,
                ),
              );
            },
            icon: const Icon(Icons.folder_open_outlined),
            label: Text(strings.aiOpenDocumentsAction),
          ),
        ],
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

class _ScoreChip extends StatelessWidget {
  const _ScoreChip({
    required this.score,
  });

  final int score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE6ECF5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'Score $score',
        style: const TextStyle(
          color: Color(0xFF335C8A),
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
