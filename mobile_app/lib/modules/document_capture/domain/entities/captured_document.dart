class CapturedDocument {
  const CapturedDocument({
    required this.fileName,
    required this.mimeType,
    required this.bytes,
  });

  final String fileName;
  final String mimeType;
  final List<int> bytes;

  bool get isPdf => mimeType == 'application/pdf';
}
