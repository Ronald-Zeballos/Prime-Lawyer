import { ContractTemplateDto } from '../../application/dto/contract-template.dto';

export class ContractTemplateResponse {
  id!: string;
  slug!: string;
  name!: string;
  description!: string | null;
  priceCents!: number;
  currency!: string;
  isActive!: boolean;
  fieldCount!: number;
  schema!: ContractTemplateDto['schema'];
  createdAt!: string;
  updatedAt!: string;

  static fromDto(dto: ContractTemplateDto): ContractTemplateResponse {
    return {
      id: dto.id,
      slug: dto.slug,
      name: dto.name,
      description: dto.description,
      priceCents: dto.priceCents,
      currency: dto.currency,
      isActive: dto.isActive,
      fieldCount: dto.fieldCount,
      schema: dto.schema,
      createdAt: dto.createdAt.toISOString(),
      updatedAt: dto.updatedAt.toISOString(),
    };
  }
}
