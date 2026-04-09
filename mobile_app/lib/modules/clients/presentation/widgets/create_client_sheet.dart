import 'package:flutter/material.dart';

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
                  'Create client',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: 'First name'),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'First name is required.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(labelText: 'Last name'),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Last name is required.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _documentNumberController,
                  decoration: const InputDecoration(labelText: 'Document number'),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Document number is required.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    final normalizedValue = (value ?? '').trim();

                    if (normalizedValue.isEmpty) {
                      return null;
                    }

                    if (!normalizedValue.contains('@')) {
                      return 'Email format looks invalid.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: 'Notes'),
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
                    widget.isSubmitting ? 'Creating...' : 'Create client',
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
