import '../../../case_files/domain/entities/case_file.dart';
import '../../../clients/domain/entities/client.dart';

class HomeDashboard {
  const HomeDashboard({
    required this.totalClients,
    required this.totalCaseFiles,
    required this.activeCaseFilesCount,
    required this.recentClients,
    required this.recentCaseFiles,
    required this.clientNamesById,
  });

  final int totalClients;
  final int totalCaseFiles;
  final int activeCaseFilesCount;
  final List<Client> recentClients;
  final List<CaseFile> recentCaseFiles;
  final Map<String, String> clientNamesById;

  bool get hasRecentClients => recentClients.isNotEmpty;
  bool get hasRecentCaseFiles => recentCaseFiles.isNotEmpty;

  String clientLabelFor(String clientId) {
    return clientNamesById[clientId] ?? 'Unknown client';
  }
}
