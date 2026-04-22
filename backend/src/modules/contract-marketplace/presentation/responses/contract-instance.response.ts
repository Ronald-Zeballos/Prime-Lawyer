import { ContractInstanceDto } from '../../application/dto/contract-instance.dto';

export class ContractInstanceResponse {
  id!: string;
  templateId!: string;
  templateSlug!: string;
  templateName!: string;
  templateDescription!: string | null;
  priceCents!: number;
  currency!: string;
  documentTitle!: string;
  summary!: string;
  fileName!: string;
  values!: ContractInstanceDto['values'];
  sections!: ContractInstanceDto['sections'];
  signatureLines!: ContractInstanceDto['signatureLines'];
  notes!: string[];
  pdfAvailable!: boolean;
  createdAt!: string;
  updatedAt!: string;

  static fromDto(dto: ContractInstanceDto): ContractInstanceResponse {
    return {
      id: dto.id,
      templateId: dto.templateId,
      templateSlug: dto.templateSlug,
      templateName: dto.templateName,
      templateDescription: dto.templateDescription,
      priceCents: dto.priceCents,
      currency: dto.currency,
      documentTitle: dto.documentTitle,
      summary: dto.summary,
      fileName: dto.fileName,
      values: dto.values,
      sections: dto.sections,
      signatureLines: dto.signatureLines,
      notes: dto.notes,
      pdfAvailable: dto.pdfAvailable,
      createdAt: dto.createdAt.toISOString(),
      updatedAt: dto.updatedAt.toISOString(),
    };
  }
}
