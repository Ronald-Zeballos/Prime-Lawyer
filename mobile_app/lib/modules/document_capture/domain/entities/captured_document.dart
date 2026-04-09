class CapturedDocument {
  const CapturedDocument({
    required this.fileName,
    required this.bytes,
  });

  final String fileName;
  final List<int> bytes;
}
