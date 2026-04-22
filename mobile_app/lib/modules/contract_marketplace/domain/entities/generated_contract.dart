class GeneratedContractValue {
  const GeneratedContractValue({
    required this.key,
    required this.label,
    required this.value,
  });

  final String key;
  final String label;
  final String value;
}

class GeneratedContractSection {
  const GeneratedContractSection({
    required this.heading,
    required this.body,
  });

  final String heading;
  final String body;
}

class GeneratedContractSignatureLine {
  const GeneratedContractSignatureLine({
    required this.label,
    required this.signerName,
  });

  final String label;
  final String signerName;
}

class GeneratedContract {
  const GeneratedContract({
    required this.id,
    required this.templateId,
    required this.templateSlug,
    required this.templateName,
    required this.templateDescription,
    required this.priceCents,
    required this.currency,
    required this.documentTitle,
    required this.summary,
    required this.fileName,
    required this.values,
    required this.sections,
    required this.signatureLines,
    required this.notes,
    required this.pdfAvailable,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String templateId;
  final String templateSlug;
  final String templateName;
  final String? templateDescription;
  final int priceCents;
  final String currency;
  final String documentTitle;
  final String summary;
  final String fileName;
  final List<GeneratedContractValue> values;
  final List<GeneratedContractSection> sections;
  final List<GeneratedContractSignatureLine> signatureLines;
  final List<String> notes;
  final bool pdfAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;
}
