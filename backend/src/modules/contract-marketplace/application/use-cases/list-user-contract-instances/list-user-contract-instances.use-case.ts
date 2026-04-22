import { Injectable } from '@nestjs/common';
import { UseCase } from '../../../../../shared/application/use-case';
import { PrismaService } from '../../../../../shared/infrastructure/prisma/prisma.service';
import {
  ContractInstanceDto,
  normalizeStoredGeneratedContractData,
} from '../../dto/contract-instance.dto';

export type ListUserContractInstancesQuery = {
  requesterId: string;
};

@Injectable()
export class ListUserContractInstancesUseCase
  implements
    UseCase<ListUserContractInstancesQuery, ContractInstanceDto[]>
{
  constructor(private readonly prisma: PrismaService) {}

  async execute(
    query: ListUserContractInstancesQuery,
  ): Promise<ContractInstanceDto[]> {
    const instances = await this.prisma.contractInstance.findMany({
      where: { userId: query.requesterId.trim() },
      include: {
        template: true,
      },
      orderBy: [{ createdAt: 'desc' }],
      take: 50,
    });

    return instances.map((instance) => {
      const generatedData = normalizeStoredGeneratedContractData(
        instance.generatedData,
      );

      return {
        id: instance.id,
        templateId: instance.templateId,
        templateSlug: instance.template.slug,
        templateName: instance.template.name,
        templateDescription: instance.template.description,
        priceCents: instance.template.priceCents,
        currency: instance.template.currency,
        documentTitle: generatedData.documentTitle,
        summary: generatedData.summary,
        fileName: generatedData.fileName,
        values: generatedData.values,
        sections: generatedData.sections,
        signatureLines: generatedData.signatureLines,
        notes: generatedData.notes,
        pdfAvailable: instance.pdfPath != null,
        createdAt: instance.createdAt,
        updatedAt: instance.updatedAt,
      };
    });
  }
}
