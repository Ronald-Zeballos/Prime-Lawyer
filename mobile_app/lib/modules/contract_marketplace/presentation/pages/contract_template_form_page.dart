import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../shared/localization/app_strings_context.dart';
import '../../../../shared/widgets/prime_brand_app_bar.dart';
import '../../../../shared/widgets/prime_page_scaffold.dart';
import '../../domain/entities/contract_template.dart';
import '../../domain/usecases/generate_contract_use_case.dart';
import '../../domain/usecases/get_contract_template_use_case.dart';
import '../controllers/contract_template_form_controller.dart';
import 'generated_contract_viewer_page.dart';

class ContractTemplateFormPage extends StatelessWidget {
  const ContractTemplateFormPage({
    super.key,
    required this.templateSlug,
  });

  final String templateSlug;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ContractTemplateFormController>(
      create: (context) => ContractTemplateFormController(
        getContractTemplateUseCase: context.read<GetContractTemplateUseCase>(),
        generateContractUseCase: context.read<GenerateContractUseCase>(),
      )..load(templateSlug),
      child: _ContractTemplateFormView(templateSlug: templateSlug),
    );
  }
}

class _ContractTemplateFormView extends StatelessWidget {
  const _ContractTemplateFormView({
    required this.templateSlug,
  });

  final String templateSlug;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ContractTemplateFormController>();
    final template = controller.template;
    final strings = context.strings;

    return PrimePageScaffold(
      appBar: PrimeBrandAppBar(
        title: strings.contractTemplateFormTitle,
        leadingIcon: Icons.arrow_back_rounded,
        leadingTooltip: strings.isSpanish ? 'Volver' : 'Back',
      ),
      body: Builder(
        builder: (context) {
          if (controller.isLoading && template == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.errorMessage != null && template == null) {
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

          if (template == null || template.schema == null) {
            return Center(
              child: Text(strings.contractTemplateUnavailable),
            );
          }

          return _DynamicContractForm(
            template: template,
            isSubmitting: controller.isSubmitting,
            errorMessage: controller.errorMessage,
            onSubmit: (values) async {
              final generatedContract = await context
                  .read<ContractTemplateFormController>()
                  .generateContract(templateSlug, values);

              if (!context.mounted || generatedContract == null) {
                return;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(strings.contractGeneratedSuccess),
                ),
              );

              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => GeneratedContractViewerPage(
                    contract: generatedContract,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _DynamicContractForm extends StatefulWidget {
  const _DynamicContractForm({
    required this.template,
    required this.isSubmitting,
    required this.errorMessage,
    required this.onSubmit,
  });

  final ContractTemplate template;
  final bool isSubmitting;
  final String? errorMessage;
  final Future<void> Function(Map<String, dynamic> values) onSubmit;

  @override
  State<_DynamicContractForm> createState() => _DynamicContractFormState();
}

class _DynamicContractFormState extends State<_DynamicContractForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String?> _selectedValues = {};
  final Map<String, bool> _booleanValues = {};

  ContractTemplateSchema get _schema => widget.template.schema!;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  @override
  void didUpdateWidget(covariant _DynamicContractForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.template.id != widget.template.id) {
      for (final controller in _controllers.values) {
        controller.dispose();
      }

      _controllers.clear();
      _selectedValues.clear();
      _booleanValues.clear();
      _initializeFields();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final groupedFields = <String, List<ContractTemplateField>>{};

    for (final field in _schema.fields) {
      final groupName =
          (field.group ?? strings.contractGeneralGroupLabel).trim();
      groupedFields
          .putIfAbsent(groupName, () => <ContractTemplateField>[])
          .add(field);
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.softBeige,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.template.name,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              if ((widget.template.description ?? '').trim().isNotEmpty)
                Text(widget.template.description!),
              if ((widget.template.description ?? '').trim().isNotEmpty)
                const SizedBox(height: 12),
              Text(_schema.summary),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(label: _schema.category),
                  _InfoChip(
                    label:
                        strings.contractFieldCountLabel(_schema.fields.length),
                  ),
                  _InfoChip(
                    label: _formatPrice(
                      widget.template.priceCents,
                      widget.template.currency,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final entry in groupedFields.entries) ...[
                Text(
                  entry.key,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                for (final field in entry.value) ...[
                  _buildField(context, field),
                  const SizedBox(height: 14),
                ],
                const SizedBox(height: 8),
              ],
              if (widget.errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.errorSoft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    widget.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: widget.isSubmitting ? null : _submit,
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: Text(
                  widget.isSubmitting
                      ? strings.contractGenerating
                      : strings.contractGenerateAction,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildField(BuildContext context, ContractTemplateField field) {
    final strings = context.strings;

    switch (field.type) {
      case 'textarea':
        return TextFormField(
          controller: _controllers[field.key],
          minLines: 3,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: field.label,
            hintText: field.placeholder,
            helperText: field.helperText,
          ),
          validator: (value) => _validateRequiredField(
            strings,
            field,
            value,
          ),
        );
      case 'number':
        return TextFormField(
          controller: _controllers[field.key],
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: field.label,
            hintText: field.placeholder,
            helperText: field.helperText,
          ),
          validator: (value) => _validateRequiredField(
            strings,
            field,
            value,
          ),
        );
      case 'date':
        return TextFormField(
          controller: _controllers[field.key],
          readOnly: true,
          decoration: InputDecoration(
            labelText: field.label,
            hintText: field.placeholder,
            helperText: field.helperText,
            suffixIcon: const Icon(Icons.calendar_today_outlined),
          ),
          validator: (value) => _validateRequiredField(
            strings,
            field,
            value,
          ),
          onTap: widget.isSubmitting ? null : () => _pickDate(field.key),
        );
      case 'select':
        return DropdownButtonFormField<String>(
          initialValue: _selectedValues[field.key],
          decoration: InputDecoration(
            labelText: field.label,
            helperText: field.helperText,
          ),
          items: field.options
              .map(
                (option) => DropdownMenuItem<String>(
                  value: option.value,
                  child: Text(option.label),
                ),
              )
              .toList(),
          onChanged: widget.isSubmitting
              ? null
              : (value) {
                  setState(() {
                    _selectedValues[field.key] = value;
                  });
                },
          validator: (value) {
            if (field.required && (value ?? '').trim().isEmpty) {
              return strings.contractFieldRequired(field.label);
            }

            return null;
          },
        );
      case 'boolean':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(16),
          ),
          child: SwitchListTile.adaptive(
            value: _booleanValues[field.key] ?? false,
            onChanged: widget.isSubmitting
                ? null
                : (value) {
                    setState(() {
                      _booleanValues[field.key] = value;
                    });
                  },
            title: Text(field.label),
            subtitle: field.helperText == null ? null : Text(field.helperText!),
            contentPadding: EdgeInsets.zero,
          ),
        );
      default:
        return TextFormField(
          controller: _controllers[field.key],
          decoration: InputDecoration(
            labelText: field.label,
            hintText: field.placeholder,
            helperText: field.helperText,
          ),
          validator: (value) => _validateRequiredField(
            strings,
            field,
            value,
          ),
        );
    }
  }

  String? _validateRequiredField(
    dynamic strings,
    ContractTemplateField field,
    String? value,
  ) {
    if (field.required && (value ?? '').trim().isEmpty) {
      return strings.contractFieldRequired(field.label);
    }

    return null;
  }

  Future<void> _pickDate(String key) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (!mounted || selectedDate == null) {
      return;
    }

    final month = selectedDate.month.toString().padLeft(2, '0');
    final day = selectedDate.day.toString().padLeft(2, '0');

    _controllers[key]?.text = '${selectedDate.year}-$month-$day';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final values = <String, dynamic>{};

    for (final field in _schema.fields) {
      switch (field.type) {
        case 'select':
          values[field.key] = _selectedValues[field.key];
          break;
        case 'boolean':
          values[field.key] = _booleanValues[field.key] ?? false;
          break;
        default:
          values[field.key] = _controllers[field.key]?.text.trim();
          break;
      }
    }

    await widget.onSubmit(values);
  }

  void _initializeFields() {
    for (final field in _schema.fields) {
      switch (field.type) {
        case 'select':
          _selectedValues[field.key] = field.defaultValue as String?;
          break;
        case 'boolean':
          _booleanValues[field.key] = field.defaultValue as bool? ?? false;
          break;
        default:
          _controllers[field.key] = TextEditingController(
            text: field.defaultValue?.toString() ?? '',
          );
          break;
      }
    }
  }

  String _formatPrice(int priceCents, String currency) {
    final majorUnits = (priceCents / 100).toStringAsFixed(2);

    return '$currency $majorUnits';
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label),
    );
  }
}
