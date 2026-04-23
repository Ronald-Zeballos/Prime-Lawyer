import 'package:flutter/material.dart';

import '../../../../shared/localization/app_strings_context.dart';
import '../../domain/repositories/client_repository.dart';

class CreateClientSheet extends StatefulWidget {
  const CreateClientSheet({
    super.key,
    required this.onSubmit,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final Future<bool> Function(CreateClientInput input) onSubmit;
  final bool isSubmitting;
  final String? errorMessage;

  @override
  State<CreateClientSheet> createState() => _CreateClientSheetState();
}

class _CreateClientSheetState extends State<CreateClientSheet> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _documentNumberController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _documentNumberController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
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
                  strings.createClientTitle,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _firstNameController,
                  decoration:
                      InputDecoration(labelText: strings.firstNameLabel),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return strings.firstNameRequiredError;
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(labelText: strings.lastNameLabel),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return strings.lastNameRequiredError;
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _documentNumberController,
                  decoration: InputDecoration(
                    labelText: strings.documentNumberLabel,
                  ),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return strings.documentNumberRequiredError;
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: strings.phoneLabel),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: strings.emailLabel),
                  validator: (value) {
                    final normalizedValue = (value ?? '').trim();

                    if (normalizedValue.isEmpty) {
                      return null;
                    }

                    if (!normalizedValue.contains('@')) {
                      return strings.emailInvalidError;
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(labelText: strings.addressLabel),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: InputDecoration(labelText: strings.notesLabel),
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
                  onPressed: widget.isSubmitting ? null : _submit,
                  child: Text(
                    widget.isSubmitting
                        ? strings.creating
                        : strings.createClientAction,
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
      CreateClientInput(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        documentNumber: _documentNumberController.text.trim(),
        phone: _normalizeOptionalText(_phoneController.text),
        email: _normalizeOptionalText(_emailController.text),
        address: _normalizeOptionalText(_addressController.text),
        notes: _normalizeOptionalText(_notesController.text),
      ),
    );

    if (!mounted || !wasCreated) {
      return;
    }

    Navigator.of(context).pop();
  }

  String? _normalizeOptionalText(String value) {
    final normalizedValue = value.trim();

    if (normalizedValue.isEmpty) {
      return null;
    }

    return normalizedValue;
  }
}
