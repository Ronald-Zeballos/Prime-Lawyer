class ContractTemplateFieldOption {
  const ContractTemplateFieldOption({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;
}

class ContractTemplateField {
  const ContractTemplateField({
    required this.key,
    required this.type,
    required this.label,
    required this.required,
    required this.placeholder,
    required this.helperText,
    required this.group,
    required this.defaultValue,
    required this.options,
  });

  final String key;
  final String type;
  final String label;
  final bool required;
  final String? placeholder;
  final String? helperText;
  final String? group;
  final Object? defaultValue;
  final List<ContractTemplateFieldOption> options;
}

class ContractTemplateSection {
  const ContractTemplateSection({
    required this.heading,
    required this.body,
  });

  final String heading;
  final String body;
}

class ContractTemplateSignatureLine {
  const ContractTemplateSignatureLine({
    required this.label,
    required this.valueKey,
  });

  final String label;
  final String valueKey;
}

class ContractTemplateSchema {
  const ContractTemplateSchema({
    required this.version,
    required this.category,
    required this.documentTitle,
    required this.summary,
    required this.fields,
    required this.sections,
    required this.signatureLines,
    required this.notes,
  });

  final int version;
  final String category;
  final String documentTitle;
  final String summary;
  final List<ContractTemplateField> fields;
  final List<ContractTemplateSection> sections;
  final List<ContractTemplateSignatureLine> signatureLines;
  final List<String> notes;
}

class ContractTemplate {
  const ContractTemplate({
    required this.id,
    required this.slug,
    required this.name,
    required this.description,
    required this.priceCents,
    required this.currency,
    required this.isActive,
    required this.fieldCount,
    required this.schema,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String slug;
  final String name;
  final String? description;
  final int priceCents;
  final String currency;
  final bool isActive;
  final int fieldCount;
  final ContractTemplateSchema? schema;
  final DateTime createdAt;
  final DateTime updatedAt;
}
