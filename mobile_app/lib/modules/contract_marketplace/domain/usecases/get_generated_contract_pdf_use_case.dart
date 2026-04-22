import '../entities/contract_pdf_file.dart';
import '../repositories/contract_marketplace_repository.dart';

class GetGeneratedContractPdfUseCase {
  const GetGeneratedContractPdfUseCase(this._repository);

  final ContractMarketplaceRepository _repository;

  Future<ContractPdfFile> execute({
    required String contractInstanceId,
    required String fileName,
  }) {
    return _repository.getGeneratedContractPdf(
      contractInstanceId: contractInstanceId,
      fileName: fileName,
    );
  }
}
