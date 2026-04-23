import 'package:flutter/material.dart';

import '../../../../shared/localization/app_strings_context.dart';

class ClientFormData {
  const ClientFormData({
    required this.firstName,
    required this.lastName,
    required this.documentNumber,
    this.phone,
    this.email,
    this.address,
    this.notes,
  });

  final String firstName;
  final String lastName;
  final String documentNumber;
  final String? phone;
  final String? email;
  final String? address;
  final String? notes;
}

class ClientFormSheet extends StatefulWidget {
  const ClientFormSheet({
    super.key,
    required this.title,
    required this.submitLabel,
    required this.submittingLabel,
    required this.onSubmit,
    this.showHeader = true,
    this.initialData,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final String title;
  final String submitLabel;
  final String submittingLabel;
  final Future<bool> Function(ClientFormData input) onSubmit;
  final bool showHeader;
  final ClientFormData? initialData;
  final bool isSubmitting;
  final String? errorMessage;

  @override
  State<ClientFormSheet> createState() => _ClientFormSheetState();
}

class _ClientFormSheetState extends State<ClientFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _documentNumberController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final initialData = widget.initialData;
    _firstNameController = TextEditingController(
      text: initialData?.firstName ?? '',
    );
    _lastNameController = TextEditingController(
      text: initialData?.lastName ?? '',
    );
    _documentNumberController = TextEditingController(
      text: initialData?.documentNumber ?? '',
    );
    _phoneController = TextEditingController(
      text: initialData?.phone ?? '',
    );
    _emailController = TextEditingController(
      text: initialData?.email ?? '',
    );
    _addressController = TextEditingController(
      text: initialData?.address ?? '',
    );
    _notesController = TextEditingController(
      text: initialData?.notes ?? '',
    );
  }

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
                if (widget.showHeader) ...[
                  Text(
                    widget.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(labelText: strings.firstNameLabel),
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
                        ? widget.submittingLabel
                        : widget.submitLabel,
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

    final wasSaved = await widget.onSubmit(
      ClientFormData(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        documentNumber: _documentNumberController.text.trim(),
        phone: _normalizeOptionalText(_phoneController.text),
        email: _normalizeOptionalText(_emailController.text),
        address: _normalizeOptionalText(_addressController.text),
        notes: _normalizeOptionalText(_notesController.text),
      ),
    );

    if (!mounted || !wasSaved) {
      return;
    }

    Navigator.of(context).pop(true);
  }

  String? _normalizeOptionalText(String value) {
    final normalizedValue = value.trim();

    if (normalizedValue.isEmpty) {
      return null;
    }

    return normalizedValue;
  }
}
