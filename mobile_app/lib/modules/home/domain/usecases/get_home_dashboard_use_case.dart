import '../../../case_files/domain/entities/case_file.dart';
import '../../../case_files/domain/repositories/case_file_repository.dart';
import '../../../clients/domain/entities/client.dart';
import '../../../clients/domain/repositories/client_repository.dart';
import '../entities/home_dashboard.dart';

class GetHomeDashboardUseCase {
  const GetHomeDashboardUseCase({
    required ClientRepository clientRepository,
    required CaseFileRepository caseFileRepository,
  })  : _clientRepository = clientRepository,
        _caseFileRepository = caseFileRepository;

  final ClientRepository _clientRepository;
  final CaseFileRepository _caseFileRepository;

  Future<HomeDashboard> execute() async {
    final results = await Future.wait<dynamic>([
      _clientRepository.getClients(),
      _caseFileRepository.getCaseFiles(),
    ]);

    final clients = results[0] as List<Client>;
    final caseFiles = results[1] as List<CaseFile>;

    final sortedClients = [...clients]
      ..sort((left, right) => right.createdAt.compareTo(left.createdAt));
    final sortedCaseFiles = [...caseFiles]
      ..sort((left, right) => right.createdAt.compareTo(left.createdAt));

    final clientNamesById = <String, String>{
      for (final client in clients) client.id: client.fullName,
    };

    final activeCaseFilesCount = caseFiles.where((caseFile) {
      return caseFile.status == 'OPEN' || caseFile.status == 'IN_PROGRESS';
    }).length;

    return HomeDashboard(
      totalClients: clients.length,
      totalCaseFiles: caseFiles.length,
      activeCaseFilesCount: activeCaseFilesCount,
      recentClients: sortedClients.take(3).toList(growable: false),
      recentCaseFiles: sortedCaseFiles.take(3).toList(growable: false),
      clientNamesById: clientNamesById,
    );
  }
}
