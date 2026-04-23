import 'package:flutter/material.dart';

import '../../../../shared/localization/app_strings_context.dart';
import '../../../clients/domain/entities/client.dart';
import '../../domain/repositories/case_file_repository.dart';

class CreateCaseFileSheet extends StatefulWidget {
  const CreateCaseFileSheet({
    super.key,
    required this.onSubmit,
    required this.clients,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final Future<bool> Function(CreateCaseFileInput input) onSubmit;
  final List<Client> clients;
  final bool isSubmitting;
  final String? errorMessage;

  @override
  State<CreateCaseFileSheet> createState() => _CreateCaseFileSheetState();
}

class _CreateCaseFileSheetState extends State<CreateCaseFileSheet> {
  static const List<String> _confidentialityOptions = [
    'STANDARD',
    'CONFIDENTIAL',
    'HIGHLY_CONFIDENTIAL',
  ];

  final _formKey = GlobalKey<FormState>();
  final _internalCodeController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _processTypeController = TextEditingController();

  String _selectedConfidentialityLevel = _confidentialityOptions.first;
  String? _selectedClientId;

  @override
  void initState() {
    super.initState();
    if (widget.clients.isNotEmpty) {
      _selectedClientId = widget.clients.first.id;
    }
  }

  @override
  void dispose() {
    _internalCodeController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _processTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  strings.createCaseFileTitle,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                if (widget.clients.isEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4E4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(strings.createClientBeforeCaseFile),
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  DropdownButtonFormField<String>(
                    initialValue: _selectedClientId,
                    decoration: InputDecoration(
                      labelText: strings.clientLabel,
                    ),
                    items: widget.clients
                        .map(
                          (client) => DropdownMenuItem<String>(
                            value: client.id,
                            child: Text(
                              '${client.fullName} · ${client.documentNumber}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: widget.isSubmitting
                        ? null
                        : (value) {
                            setState(() {
                              _selectedClientId = value;
                            });
                          },
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return strings.clientRequiredError;
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                TextFormField(
                  controller: _internalCodeController,
                  decoration: InputDecoration(
                    labelText: strings.internalCodeLabel,
                  ),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return strings.internalCodeRequiredError;
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _titleController,
                  decoration:
                      InputDecoration(labelText: strings.caseTitleLabel),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return strings.caseTitleRequiredError;
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: strings.caseDescriptionLabel,
                    hintText: strings.caseDescriptionHint,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _processTypeController,
                  decoration: InputDecoration(
                    labelText: strings.processTypeLabel,
                  ),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return strings.processTypeRequiredError;
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedConfidentialityLevel,
                  decoration: InputDecoration(
                    labelText: strings.confidentialityLevelLabel,
                  ),
                  items: _confidentialityOptions
                      .map(
                        (level) => DropdownMenuItem<String>(
                          value: level,
                          child: Text(strings.confidentialityLevel(level)),
                        ),
                      )
                      .toList(),
                  onChanged: widget.isSubmitting
                      ? null
                      : (value) {
                          if (value == null) {
                            return;
                          }

                          setState(() {
                            _selectedConfidentialityLevel = value;
                          });
                        },
                ),
                if (widget.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBE7E5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      widget.errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: widget.isSubmitting || widget.clients.isEmpty
                      ? null
                      : _submit,
                  child: Text(
                    widget.isSubmitting
                        ? strings.creating
                        : strings.createCaseFileAction,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final wasCreated = await widget.onSubmit(
      CreateCaseFileInput(
        clientId: _selectedClientId!,
        internalCode: _internalCodeController.text.trim(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        processType: _processTypeController.text.trim(),
        confidentialityLevel: _selectedConfidentialityLevel,
      ),
    );

    if (!mounted || !wasCreated) {
      return;
    }

    Navigator.of(context).pop();
  }
}
