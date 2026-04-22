import { ContractTemplateSchema } from '../../domain/services/contract-template-schema';

export type ContractTemplateDto = {
  id: string;
  slug: string;
  name: string;
  description: string | null;
  priceCents: number;
  currency: string;
  isActive: boolean;
  fieldCount: number;
  schema: ContractTemplateSchema | null;
  createdAt: Date;
  updatedAt: Date;
};
