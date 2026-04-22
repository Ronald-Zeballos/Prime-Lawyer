class ContractPdfFile {
  const ContractPdfFile({
    required this.fileName,
    required this.fileType,
    required this.bytes,
  });

  final String fileName;
  final String fileType;
  final List<int> bytes;
}
