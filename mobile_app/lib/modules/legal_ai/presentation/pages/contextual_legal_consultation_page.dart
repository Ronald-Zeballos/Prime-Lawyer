import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../shared/localization/app_strings_context.dart';
import '../../../../shared/widgets/prime_brand_app_bar.dart';
import '../../../../shared/widgets/prime_empty_state.dart';
import '../../../../shared/widgets/prime_page_scaffold.dart';
import '../../../../shared/widgets/prime_status_chip.dart';
import '../../../../shared/widgets/prime_surface_card.dart';
import '../../../case_files/domain/entities/case_file.dart';
import '../../../case_files/domain/usecases/get_case_files_use_case.dart';
import '../../../documents/domain/entities/document.dart';
import '../../../documents/domain/usecases/get_case_documents_use_case.dart';
import '../../../documents/presentation/pages/documents_page.dart';
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

    return PrimePageScaffold(
      appBar: PrimeBrandAppBar(
        title: strings.legalAiConsultationTitle,
        leadingIcon: Icons.arrow_back_rounded,
        leadingTooltip: strings.isSpanish ? 'Volver' : 'Back',
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
            padding: const EdgeInsets.fromLTRB(
              AppTheme.pagePadding,
              8,
              AppTheme.pagePadding,
              40,
            ),
            children: [
              _AiHeroBanner(
                selectedCaseFile: controller.selectedCaseFile,
                selectedDocument: controller.selectedDocument,
              ),
              const SizedBox(height: 16),
              PrimeSurfaceCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.legalAiQuestionCardTitle,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        strings.legalAiQuestionCardDescription,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 18),
                      _ContextSelector(
                        label: strings.aiCaseContextLabel,
                        value: controller.selectedCaseFile?.displayLabel ??
                            strings.aiNoSpecificCase,
                        helper: strings.aiSelectCaseFirstHint,
                        enabled: true,
                        onTap: () => _pickCaseContext(context, controller),
                      ),
                      const SizedBox(height: 14),
                      _ContextSelector(
                        label: strings.aiDocumentContextLabel,
                        value: controller.selectedDocument?.originalName ??
                            strings.aiNoSpecificDocument,
                        helper: controller.selectedCaseFile == null
                            ? strings.aiSelectCaseFirstHint
                            : controller.isLoadingDocuments
                                ? strings.aiLoadingDocuments
                                : controller.hasDocuments
                                    ? strings.aiDocumentContextHelper
                                    : strings.aiNoDocumentsForSelectedCase,
                        enabled: controller.selectedCaseFile != null &&
                            !controller.isLoadingDocuments,
                        onTap: controller.selectedCaseFile == null ||
                                controller.isLoadingDocuments
                            ? null
                            : () => _pickDocumentContext(context, controller),
                      ),
                      if (controller.selectedCaseFile != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.softBeige,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            strings.aiProcessTypeAutoHint(
                              controller.selectedCaseFile!.processType,
                            ),
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _SuggestionChip(
                            label: strings.aiSuggestionSummary,
                            onTap: () => _useSuggestion(
                              strings.aiSuggestionSummaryQuestion,
                            ),
                          ),
                          _SuggestionChip(
                            label: strings.aiSuggestionDocuments,
                            onTap: () => _useSuggestion(
                              strings.aiSuggestionDocumentsQuestion,
                            ),
                          ),
                          _SuggestionChip(
                            label: strings.aiSuggestionNextSteps,
                            onTap: () => _useSuggestion(
                              strings.aiSuggestionNextStepsQuestion,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _questionController,
                        minLines: 4,
                        maxLines: 6,
                        decoration: InputDecoration(
                          labelText: strings.aiQuestionLabel,
                          hintText: strings.aiQuestionHint,
                          alignLabelWithHint: true,
                        ),
                        onChanged: (_) => controller.clearError(),
                        validator: (value) {
                          if ((value?.trim() ?? '').isEmpty) {
                            return strings.aiQuestionRequiredError;
                          }

                          return null;
                        },
                      ),
                      if (controller.errorMessage != null) ...[
                        const SizedBox(height: 16),
                        _AiErrorBanner(message: controller.errorMessage!),
                      ],
                      const SizedBox(height: 20),
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
              if (controller.hasConsultationHistory) ...[
                const SizedBox(height: AppTheme.sectionSpacing),
                _AnswerHistorySection(
                  consultations: controller.consultationHistory,
                  currentQueryId: controller.answer?.queryId,
                  onOpenConsultation: (answer) =>
                      _openPreviousConsultation(context, answer),
                ),
              ],
              const SizedBox(height: AppTheme.sectionSpacing),
              if (!controller.hasAnswer)
                PrimeSurfaceCard(
                  child: PrimeEmptyState(
                    icon: Icons.auto_awesome_outlined,
                    title: strings.aiNoAnswerYetTitle,
                    description: strings.aiNoAnswerYetDescription,
                  ),
                )
              else
                _AnswerView(
                  answer: controller.answer!,
                  onCopyAnswer: () => _copyAnswer(context, controller.answer!),
                  onStartNewQuestion: () => _startNewQuestion(context),
                  onUseFollowUpQuestion: _prepareFollowUpQuestion,
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

  void _useSuggestion(String question) {
    _questionController
      ..text = question
      ..selection = TextSelection.collapsed(offset: question.length);
  }

  Future<void> _openPreviousConsultation(
    BuildContext context,
    ContextualLegalAnswer answer,
  ) async {
    _questionController
      ..text = answer.question
      ..selection = TextSelection.collapsed(offset: answer.question.length);

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
      ..selection = TextSelection.collapsed(offset: question.length);

    if (!_scrollController.hasClients) {
      return;
    }

    await _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _pickCaseContext(
    BuildContext context,
    ContextualLegalConsultationController controller,
  ) async {
    final strings = context.strings;
    final selectedCaseId = await showModalBottomSheet<String?>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            children: [
              Text(
                strings.aiCaseContextLabel,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(strings.aiNoSpecificCase),
                trailing: controller.selectedCaseFileId == null
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () => Navigator.of(context).pop(null),
              ),
              for (final caseFile in controller.caseFiles)
                ListTile(
                  title: Text(
                    caseFile.displayLabel,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(caseFile.processType),
                  trailing: controller.selectedCaseFileId == caseFile.id
                      ? const Icon(Icons.check_rounded)
                      : null,
                  onTap: () => Navigator.of(context).pop(caseFile.id),
                ),
            ],
          ),
        );
      },
    );

    if (!mounted) {
      return;
    }

    await controller.selectCaseFile(selectedCaseId);
  }

  Future<void> _pickDocumentContext(
    BuildContext context,
    ContextualLegalConsultationController controller,
  ) async {
    final strings = context.strings;
    final selectedDocumentId = await showModalBottomSheet<String?>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            children: [
              Text(
                strings.aiDocumentContextLabel,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(strings.aiNoSpecificDocument),
                trailing: controller.selectedDocumentId == null
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () => Navigator.of(context).pop(null),
              ),
              for (final document in controller.documents)
                ListTile(
                  title: Text(
                    document.originalName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(strings.ocrStatus(document.ocrStatus)),
                  trailing: controller.selectedDocumentId == document.id
                      ? const Icon(Icons.check_rounded)
                      : null,
                  onTap: () => Navigator.of(context).pop(document.id),
                ),
            ],
          ),
        );
      },
    );

    if (!mounted) {
      return;
    }

    controller.selectDocument(selectedDocumentId);
  }
}

class _AiHeroBanner extends StatelessWidget {
  const _AiHeroBanner({
    required this.selectedCaseFile,
    required this.selectedDocument,
  });

  final CaseFile? selectedCaseFile;
  final Document? selectedDocument;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppTheme.primaryNavy,
            AppTheme.secondaryNavy,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(34),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PrimeStatusChip.accent(strings.legalAiContextualBadge),
          const SizedBox(height: 16),
          Text(
            strings.legalAiConsultationTitle,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppTheme.surface,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            strings.legalAiConsultationSubtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.surface.withValues(alpha: 0.92),
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeroContextPill(
                label: selectedCaseFile == null
                    ? strings.aiNoSpecificCase
                    : strings.selectedCaseContextLabel(
                        selectedCaseFile!.internalCode,
                      ),
              ),
              _HeroContextPill(
                label: selectedDocument == null
                    ? strings.aiNoSpecificDocument
                    : strings.selectedDocumentContextLabel(
                        selectedDocument!.originalName,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroContextPill extends StatelessWidget {
  const _HeroContextPill({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppTheme.surface,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _ContextSelector extends StatelessWidget {
  const _ContextSelector({
    required this.label,
    required this.value,
    required this.helper,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final String value;
  final String helper;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        const SizedBox(height: 8),
        Material(
          color: enabled ? AppTheme.surface : AppTheme.neutralSoft,
          borderRadius: BorderRadius.circular(22),
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppTheme.softBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: enabled
                                ? AppTheme.textPrimary
                                : AppTheme.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: enabled
                        ? AppTheme.textSecondary
                        : AppTheme.textSecondary.withValues(alpha: 0.45),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          helper,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      label: Text(label),
    );
  }
}

class _AnswerHistorySection extends StatelessWidget {
  const _AnswerHistorySection({
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.aiConsultationHistoryTitle,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          strings.aiConsultationHistoryDescription,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 14),
        for (final answer in consultations) ...[
          PrimeSurfaceCard(
            color: answer.queryId == currentQueryId
                ? const Color(0xFFFBF7EF)
                : AppTheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        answer.question,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    PrimeStatusChip.neutral(
                      strings.aiGroundingStatus(answer.groundingStatus),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  strings.aiHistoryContextSummary(
                    answer.usedContextCases.length,
                    answer.usedContextDocuments.length,
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 14),
                TextButton.icon(
                  onPressed: () => onOpenConsultation(answer),
                  icon: const Icon(Icons.history_toggle_off_rounded),
                  label: Text(
                    context.strings.isSpanish
                        ? 'Reabrir consulta'
                        : 'Reopen consultation',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _AnswerView extends StatelessWidget {
  const _AnswerView({
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
        PrimeSurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      strings.aiResponseTitle,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  PrimeStatusChip(
                    label: strings.aiGroundingStatus(answer.groundingStatus),
                    palette: answer.isGrounded
                        ? PrimeChipStyles.caseStatus('OPEN')
                        : answer.isPartial
                            ? PrimeChipStyles.caseStatus('IN_PROGRESS')
                            : PrimeChipStyles.neutral,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                answer.answer,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: onCopyAnswer,
                    icon: const Icon(Icons.copy_all_rounded),
                    label: Text(strings.aiCopyAnswerAction),
                  ),
                  OutlinedButton.icon(
                    onPressed: onStartNewQuestion,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(strings.aiNewQuestionAction),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (answer.hasSourceCase)
          _SourceCaseCard(sourceCase: answer.sourceCaseFile!),
        if (answer.hasSourceCase) const SizedBox(height: 16),
        if (answer.hasSourceDocument)
          _SourceDocumentCard(sourceDocument: answer.sourceDocument!),
        if (answer.hasSourceDocument) const SizedBox(height: 16),
        _ContextCasesCard(answer: answer),
        const SizedBox(height: 16),
        _ContextDocumentsCard(answer: answer),
        const SizedBox(height: 16),
        _BulletListCard(
          title: strings.aiRecommendedNextStepsTitle,
          items: answer.recommendedNextSteps,
          emptyText: strings.isSpanish
              ? 'No hay siguientes pasos sugeridos todavía.'
              : 'There are no suggested next steps yet.',
        ),
        const SizedBox(height: 16),
        _BulletListCard(
          title: strings.aiLimitationsTitle,
          items: answer.limitations,
          emptyText: strings.isSpanish
              ? 'No se registraron límites adicionales.'
              : 'No extra limitations were registered.',
        ),
        if (answer.followUpQuestions.isNotEmpty) ...[
          const SizedBox(height: 16),
          PrimeSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.aiFollowUpQuestionsTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final question in answer.followUpQuestions)
                      ActionChip(
                        onPressed: () => onUseFollowUpQuestion(question),
                        label: Text(question),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _SourceCaseCard extends StatelessWidget {
  const _SourceCaseCard({
    required this.sourceCase,
  });

  final LegalAiSourceCaseFile sourceCase;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return PrimeSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.aiSourceCaseTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            sourceCase.displayLabel,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          if ((sourceCase.descriptionSnippet ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              sourceCase.descriptionSnippet!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              PrimeStatusChip.caseStatus(
                status: sourceCase.status,
                label: strings.caseStatus(sourceCase.status),
              ),
              PrimeStatusChip.neutral(sourceCase.processType),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed(
                AppRoutes.caseFileDetail,
                arguments: sourceCase.id,
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

class _SourceDocumentCard extends StatelessWidget {
  const _SourceDocumentCard({
    required this.sourceDocument,
  });

  final LegalAiSourceDocument sourceDocument;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return PrimeSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.aiSourceDocumentTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            sourceDocument.originalName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              PrimeStatusChip.neutral(sourceDocument.fileType),
              PrimeStatusChip.neutral(
                strings.ocrStatus(sourceDocument.ocrStatus),
              ),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => DocumentsPage(
                    args: DocumentsPageArgs(
                      caseFileId: sourceDocument.caseFileId,
                      caseFileTitle: sourceDocument.originalName,
                    ),
                  ),
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

class _ContextCasesCard extends StatelessWidget {
  const _ContextCasesCard({
    required this.answer,
  });

  final ContextualLegalAnswer answer;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return PrimeSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.aiUsedCasesTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          if (!answer.hasUsedContextCases)
            Text(strings.aiNoContextCases)
          else
            for (final item in answer.usedContextCases) ...[
              _ContextCaseTile(item: item),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _ContextDocumentsCard extends StatelessWidget {
  const _ContextDocumentsCard({
    required this.answer,
  });

  final ContextualLegalAnswer answer;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return PrimeSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.aiUsedDocumentsTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          if (!answer.hasUsedContextDocuments)
            Text(strings.aiNoContextDocuments)
          else
            for (final item in answer.usedContextDocuments) ...[
              _ContextDocumentTile(item: item),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _ContextCaseTile extends StatelessWidget {
  const _ContextCaseTile({
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
        color: AppTheme.appBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.softBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.displayLabel,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              PrimeStatusChip.caseStatus(
                status: item.status,
                label: strings.caseStatus(item.status),
              ),
              PrimeStatusChip.neutral(strings.aiContextRelation(item.relation)),
              PrimeStatusChip.accent('${item.score}%'),
            ],
          ),
          if ((item.snippet ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              item.snippet!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (item.matchReasons.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final reason in item.matchReasons)
                  PrimeStatusChip.neutral(reason),
              ],
            ),
          ],
          const SizedBox(height: 12),
          TextButton.icon(
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

class _ContextDocumentTile extends StatelessWidget {
  const _ContextDocumentTile({
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
        color: AppTheme.appBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.softBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.originalName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            item.caseDisplayLabel,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              PrimeStatusChip.neutral(strings.aiContextRelation(item.relation)),
              PrimeStatusChip.accent('${item.score}%'),
              PrimeStatusChip.neutral(strings.ocrStatus(item.ocrStatus)),
            ],
          ),
          if ((item.snippet ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              item.snippet!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (item.matchReasons.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final reason in item.matchReasons)
                  PrimeStatusChip.neutral(reason),
              ],
            ),
          ],
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => DocumentsPage(
                    args: DocumentsPageArgs(
                      caseFileId: item.caseFileId,
                      caseFileTitle: item.caseDisplayLabel,
                    ),
                  ),
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

class _BulletListCard extends StatelessWidget {
  const _BulletListCard({
    required this.title,
    required this.items,
    required this.emptyText,
  });

  final String title;
  final List<String> items;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    return PrimeSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Text(emptyText)
          else
            for (final item in items) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 7),
                    child: Icon(
                      Icons.circle,
                      size: 7,
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}

class _AiErrorBanner extends StatelessWidget {
  const _AiErrorBanner({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.errorSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.error.withValues(alpha: 0.16)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.error,
              ),
        ),
      ),
    );
  }
}
