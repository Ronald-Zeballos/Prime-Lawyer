import { Injectable } from '@nestjs/common';
import { NotFoundError } from '../../../../../shared/application/errors/not-found.error';
import { UseCase } from '../../../../../shared/application/use-case';
import { PrismaService } from '../../../../../shared/infrastructure/prisma/prisma.service';
import { ContractTemplateDto } from '../../dto/contract-template.dto';
import { normalizeContractTemplateSchema } from '../../../domain/services/contract-template-schema';

export type GetContractTemplateQuery = {
  slug: string;
};

@Injectable()
export class GetContractTemplateUseCase
  implements UseCase<GetContractTemplateQuery, ContractTemplateDto>
{
  constructor(private readonly prisma: PrismaService) {}

  async execute(query: GetContractTemplateQuery): Promise<ContractTemplateDto> {
    const template = await this.prisma.contractTemplate.findUnique({
      where: { slug: query.slug.trim() },
    });

    if (!template || !template.isActive) {
      throw new NotFoundError('Contract template was not found.');
    }

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
      schema,
      createdAt: template.createdAt,
      updatedAt: template.updatedAt,
    };
  }
}
