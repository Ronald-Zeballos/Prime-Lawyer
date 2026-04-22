import { randomUUID } from 'node:crypto';
import { Inject, Injectable } from '@nestjs/common';
import { NotFoundError } from '../../../../../shared/application/errors/not-found.error';
import { UseCase } from '../../../../../shared/application/use-case';
import { DomainValidationError } from '../../../../../shared/domain/errors/domain-validation.error';
import { PrismaService } from '../../../../../shared/infrastructure/prisma/prisma.service';
import {
  ContractInstanceDto,
  ContractInstanceSectionDto,
  ContractInstanceSignatureLineDto,
  ContractInstanceValueDto,
  StoredGeneratedContractData,
} from '../../dto/contract-instance.dto';
import { normalizeContractTemplateSchema } from '../../../domain/services/contract-template-schema';
import {
  CONTRACT_PDF_STORAGE,
  ContractPdfStorage,
} from './contract-pdf-storage.port';
import { ContractPdfBuilderService } from '../../../infrastructure/services/contract-pdf-builder.service';

export type GenerateContractFromTemplateCommand = {
  templateSlug: string;
  requesterId: string;
  values: Record<string, unknown>;
};

@Injectable()
export class GenerateContractFromTemplateUseCase
  implements
    UseCase<GenerateContractFromTemplateCommand, ContractInstanceDto>
{
  constructor(
    private readonly prisma: PrismaService,
    private readonly contractPdfBuilderService: ContractPdfBuilderService,
    @Inject(CONTRACT_PDF_STORAGE)
    private readonly contractPdfStorage: ContractPdfStorage,
  ) {}

  async execute(
    command: GenerateContractFromTemplateCommand,
  ): Promise<ContractInstanceDto> {
    const template = await this.prisma.contractTemplate.findUnique({
      where: { slug: command.templateSlug.trim() },
    });

    if (!template || !template.isActive) {
      throw new NotFoundError('Contract template was not found.');
    }

    const schema = normalizeContractTemplateSchema(template.schemaJson);
    const normalizedValues = this.normalizeSubmittedValues(
      schema.fields,
      command.values,
    );
    const resolvedValues = schema.fields.map((field): ContractInstanceValueDto => ({
      key: field.key,
      label: field.label,
      value: normalizedValues[field.key] ?? 'No especificado',
    }));
    const documentTitle = this.resolveText(schema.documentTitle, normalizedValues);
    const summary = this.resolveText(schema.summary, normalizedValues);
    const sections = schema.sections.map(
      (section): ContractInstanceSectionDto => ({
        heading: this.resolveText(section.heading, normalizedValues),
        body: this.resolveText(section.body, normalizedValues),
      }),
    );
    const signatureLines = schema.signatureLines.map(
      (signatureLine): ContractInstanceSignatureLineDto => ({
        label: signatureLine.label,
        signerName:
          normalizedValues[signatureLine.valueKey] ?? '________________',
      }),
    );
    const createdAt = new Date();
    const fileName = this.buildFileName(documentTitle, createdAt);
    const generatedData: StoredGeneratedContractData = {
      schemaVersion: schema.version,
      documentTitle,
      summary,
      fileName,
      values: resolvedValues,
      sections,
      signatureLines,
      notes: schema.notes,
    };
    const contractInstanceId = randomUUID();

    const createdContractInstance = await this.prisma.contractInstance.create({
      data: {
        id: contractInstanceId,
        templateId: template.id,
        userId: command.requesterId.trim(),
        generatedData,
      },
    });
    let contractDto = this.toContractInstanceDto({
      instance: createdContractInstance,
      template: {
        id: template.id,
        slug: template.slug,
        name: template.name,
        description: template.description,
        priceCents: template.priceCents,
        currency: template.currency,
      },
      generatedData,
    });
    const pdfBuffer = await this.contractPdfBuilderService.build(contractDto);
    const storedPdf = await this.contractPdfStorage.store({
      userId: command.requesterId.trim(),
      contractInstanceId,
      fileName,
      buffer: pdfBuffer,
    });

    const updatedContractInstance = await this.prisma.contractInstance.update({
      where: { id: contractInstanceId },
      data: {
        pdfPath: storedPdf.storagePath,
      },
    });

    contractDto = this.toContractInstanceDto({
      instance: updatedContractInstance,
      template: {
        id: template.id,
        slug: template.slug,
        name: template.name,
        description: template.description,
        priceCents: template.priceCents,
        currency: template.currency,
      },
      generatedData,
    });

    return contractDto;
  }

  private normalizeSubmittedValues(
    fields: ReturnType<typeof normalizeContractTemplateSchema>['fields'],
    submittedValues: Record<string, unknown>,
  ): Record<string, string> {
    const normalizedValues: Record<string, string> = {};

    for (const field of fields) {
      const rawValue = submittedValues[field.key] ?? field.defaultValue;
      const normalizedValue = this.normalizeFieldValue(field, rawValue);

      if (field.required && normalizedValue.trim().length === 0) {
        throw new DomainValidationError(
          `Contract field ${field.label} is required.`,
        );
      }

      normalizedValues[field.key] = normalizedValue.trim().length === 0
        ? 'No especificado'
        : normalizedValue.trim();
    }

    return normalizedValues;
  }

  private normalizeFieldValue(
    field: ReturnType<typeof normalizeContractTemplateSchema>['fields'][number],
    value: unknown,
  ): string {
    switch (field.type) {
      case 'boolean':
        if (typeof value === 'boolean') {
          return value ? 'Sí' : 'No';
        }

        if (typeof value === 'string' && value.trim().length > 0) {
          const normalizedBoolean = value.trim().toLowerCase();

          if (['true', 'si', 'sí', 'yes'].includes(normalizedBoolean)) {
            return 'Sí';
          }

          if (['false', 'no'].includes(normalizedBoolean)) {
            return 'No';
          }
        }

        return '';
      case 'number':
        if (typeof value === 'number' && !Number.isNaN(value)) {
          return value.toString();
        }

        if (typeof value === 'string' && value.trim().length > 0) {
          const numericValue = Number(value);

          if (!Number.isNaN(numericValue)) {
            return value.trim();
          }
        }

        return '';
      case 'select': {
        if (typeof value !== 'string' || value.trim().length === 0) {
          return '';
        }

        const selectedOption = field.options.find(
          (option) => option.value === value.trim(),
        );

        if (!selectedOption) {
          throw new DomainValidationError(
            `Contract field ${field.label} contains an unsupported option.`,
          );
        }

        return selectedOption.label;
      }
      default:
        return typeof value === 'string' ? value.trim() : '';
    }
  }

  private resolveText(
    templateText: string,
    values: Record<string, string>,
  ): string {
    return templateText.replace(/\{\{\s*([a-zA-Z0-9_]+)\s*\}\}/g, (_, key) => {
      return values[key] ?? '________________';
    });
  }

  private buildFileName(documentTitle: string, createdAt: Date): string {
    const sanitizedTitle = documentTitle
      .trim()
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/^-+|-+$/g, '');
    const datePart = createdAt.toISOString().slice(0, 10);

    return `${sanitizedTitle || 'contract'}-${datePart}.pdf`;
  }

  private toContractInstanceDto(params: {
    instance: {
      id: string;
      templateId: string;
      pdfPath: string | null;
      createdAt: Date;
      updatedAt: Date;
    };
    template: {
      id: string;
      slug: string;
      name: string;
      description: string | null;
      priceCents: number;
      currency: string;
    };
    generatedData: StoredGeneratedContractData;
  }): ContractInstanceDto {
    return {
      id: params.instance.id,
      templateId: params.instance.templateId,
      templateSlug: params.template.slug,
      templateName: params.template.name,
      templateDescription: params.template.description,
      priceCents: params.template.priceCents,
      currency: params.template.currency,
      documentTitle: params.generatedData.documentTitle,
      summary: params.generatedData.summary,
      fileName: params.generatedData.fileName,
      values: params.generatedData.values,
      sections: params.generatedData.sections,
      signatureLines: params.generatedData.signatureLines,
      notes: params.generatedData.notes,
      pdfAvailable: params.instance.pdfPath != null,
      createdAt: params.instance.createdAt,
      updatedAt: params.instance.updatedAt,
    };
  }
}
