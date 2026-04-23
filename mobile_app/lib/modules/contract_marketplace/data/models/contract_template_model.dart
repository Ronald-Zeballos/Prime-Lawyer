import '../../domain/entities/contract_template.dart';

class ContractTemplateModel extends ContractTemplate {
  ContractTemplateModel({
    required super.id,
    required super.slug,
    required super.name,
    required super.description,
    required super.priceCents,
    required super.currency,
    required super.isActive,
    required super.fieldCount,
    required super.schema,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ContractTemplateModel.fromJson(Map<String, dynamic> json) {
    return ContractTemplateModel(
      id: json['id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      priceCents: json['priceCents'] as int,
      currency: json['currency'] as String,
      isActive: json['isActive'] as bool,
      fieldCount: json['fieldCount'] as int,
      schema: _parseSchema(json['schema']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  static ContractTemplateSchema? _parseSchema(dynamic value) {
    if (value is! Map<String, dynamic>) {
      return null;
    }

    final fields = (value['fields'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(
          (field) => ContractTemplateField(
            key: field['key'] as String,
            type: field['type'] as String,
            label: field['label'] as String,
            required: field['required'] as bool? ?? false,
            placeholder: field['placeholder'] as String?,
            helperText: field['helperText'] as String?,
            group: field['group'] as String?,
            defaultValue: field['defaultValue'],
            options: (field['options'] as List<dynamic>? ?? const <dynamic>[])
                .whereType<Map<String, dynamic>>()
                .map(
                  (option) => ContractTemplateFieldOption(
                    value: option['value'] as String,
                    label: option['label'] as String,
                  ),
                )
                .toList(),
          ),
        )
        .toList();
    final sections = (value['sections'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(
          (section) => ContractTemplateSection(
            heading: section['heading'] as String,
            body: section['body'] as String,
          ),
        )
        .toList();
    final signatureLines =
        (value['signatureLines'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .map(
              (signatureLine) => ContractTemplateSignatureLine(
                label: signatureLine['label'] as String,
                valueKey: signatureLine['valueKey'] as String,
              ),
            )
            .toList();
    final notes = (value['notes'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<String>()
        .toList();

    return ContractTemplateSchema(
      version: value['version'] as int? ?? 1,
      category: value['category'] as String? ?? '',
      documentTitle: value['documentTitle'] as String? ?? '',
      summary: value['summary'] as String? ?? '',
      fields: fields,
      sections: sections,
      signatureLines: signatureLines,
      notes: notes,
    );
  }
}
