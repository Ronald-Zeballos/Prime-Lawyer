import '../../domain/entities/generated_contract.dart';

class GeneratedContractModel extends GeneratedContract {
  GeneratedContractModel({
    required super.id,
    required super.templateId,
    required super.templateSlug,
    required super.templateName,
    required super.templateDescription,
    required super.priceCents,
    required super.currency,
    required super.documentTitle,
    required super.summary,
    required super.fileName,
    required super.values,
    required super.sections,
    required super.signatureLines,
    required super.notes,
    required super.pdfAvailable,
    required super.createdAt,
    required super.updatedAt,
  });

  factory GeneratedContractModel.fromJson(Map<String, dynamic> json) {
    return GeneratedContractModel(
      id: json['id'] as String,
      templateId: json['templateId'] as String,
      templateSlug: json['templateSlug'] as String,
      templateName: json['templateName'] as String,
      templateDescription: json['templateDescription'] as String?,
      priceCents: json['priceCents'] as int,
      currency: json['currency'] as String,
      documentTitle: json['documentTitle'] as String,
      summary: json['summary'] as String,
      fileName: json['fileName'] as String,
      values: (json['values'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(
            (value) => GeneratedContractValue(
              key: value['key'] as String,
              label: value['label'] as String,
              value: value['value'] as String,
            ),
          )
          .toList(),
      sections: (json['sections'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(
            (section) => GeneratedContractSection(
              heading: section['heading'] as String,
              body: section['body'] as String,
            ),
          )
          .toList(),
      signatureLines:
          (json['signatureLines'] as List<dynamic>? ?? const <dynamic>[])
              .whereType<Map<String, dynamic>>()
              .map(
                (signatureLine) => GeneratedContractSignatureLine(
                  label: signatureLine['label'] as String,
                  signerName: signatureLine['signerName'] as String,
                ),
              )
              .toList(),
      notes: (json['notes'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<String>()
          .toList(),
      pdfAvailable: json['pdfAvailable'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
