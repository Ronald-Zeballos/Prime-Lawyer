import { Injectable } from '@nestjs/common';
import { UseCase } from '../../../../../shared/application/use-case';
import { PrismaService } from '../../../../../shared/infrastructure/prisma/prisma.service';
import { ContractTemplateDto } from '../../dto/contract-template.dto';
import { normalizeContractTemplateSchema } from '../../../domain/services/contract-template-schema';

@Injectable()
export class ListActiveContractTemplatesUseCase
  implements UseCase<void, ContractTemplateDto[]>
{
  constructor(private readonly prisma: PrismaService) {}

  async execute(): Promise<ContractTemplateDto[]> {
    const templates = await this.prisma.contractTemplate.findMany({
      where: { isActive: true },
      orderBy: [{ updatedAt: 'desc' }, { name: 'asc' }],
    });

    return templates.map((template) => {
      const schema = normalizeContractTemplateSchema(template.schemaJson);

      return {
        id: template.id,
        slug: template.slug,
        name: template.name,
        description: template.description,
        priceCents: template.priceCents,
        currency: template.currency,
        isActive: template.isActive,
        fieldCount: schema.fields.length,
        schema: null,
        createdAt: template.createdAt,
        updatedAt: template.updatedAt,
      };
    });
  }
}
