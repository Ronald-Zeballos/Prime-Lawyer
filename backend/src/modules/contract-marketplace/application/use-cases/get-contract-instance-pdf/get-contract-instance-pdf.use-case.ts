import { Inject, Injectable } from '@nestjs/common';
import { ForbiddenError } from '../../../../../shared/application/errors/forbidden.error';
import { NotFoundError } from '../../../../../shared/application/errors/not-found.error';
import { UseCase } from '../../../../../shared/application/use-case';
import { PrismaService } from '../../../../../shared/infrastructure/prisma/prisma.service';
import { normalizeStoredGeneratedContractData } from '../../dto/contract-instance.dto';
import {
  CONTRACT_PDF_STORAGE,
  ContractPdfStorage,
} from '../generate-contract-from-template/contract-pdf-storage.port';

export type GetContractInstancePdfQuery = {
  id: string;
  requesterId: string;
};

export type ContractInstancePdfDto = {
  fileName: string;
  fileType: string;
  buffer: Buffer;
};

@Injectable()
export class GetContractInstancePdfUseCase
  implements UseCase<GetContractInstancePdfQuery, ContractInstancePdfDto>
{
  constructor(
    private readonly prisma: PrismaService,
    @Inject(CONTRACT_PDF_STORAGE)
    private readonly contractPdfStorage: ContractPdfStorage,
  ) {}

  async execute(
    query: GetContractInstancePdfQuery,
  ): Promise<ContractInstancePdfDto> {
    const instance = await this.prisma.contractInstance.findUnique({
      where: { id: query.id.trim() },
    });

    if (!instance) {
      throw new NotFoundError('Generated contract was not found.');
    }

    if (instance.userId !== query.requesterId.trim()) {
      throw new ForbiddenError(
        'This generated contract is not available for the current user.',
      );
    }

    if (!instance.pdfPath) {
      throw new NotFoundError('Generated contract PDF is not available yet.');
    }

    const generatedData = normalizeStoredGeneratedContractData(
      instance.generatedData,
    );
    const storedPdf = await this.contractPdfStorage.read({
      storagePath: instance.pdfPath,
    });

    return {
      fileName: generatedData.fileName,
      fileType: 'application/pdf',
      buffer: storedPdf.buffer,
    };
  }
}
