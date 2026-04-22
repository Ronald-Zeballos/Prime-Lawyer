import { DomainValidationError } from '../../../../shared/domain/errors/domain-validation.error';

export type ContractInstanceValueDto = {
  key: string;
  label: string;
  value: string;
};

export type ContractInstanceSectionDto = {
  heading: string;
  body: string;
};

export type ContractInstanceSignatureLineDto = {
  label: string;
  signerName: string;
};

export type StoredGeneratedContractData = {
  schemaVersion: number;
  documentTitle: string;
  summary: string;
  fileName: string;
  values: ContractInstanceValueDto[];
  sections: ContractInstanceSectionDto[];
  signatureLines: ContractInstanceSignatureLineDto[];
  notes: string[];
};

export type ContractInstanceDto = {
  id: string;
  templateId: string;
  templateSlug: string;
  templateName: string;
  templateDescription: string | null;
  priceCents: number;
  currency: string;
  documentTitle: string;
  summary: string;
  fileName: string;
  values: ContractInstanceValueDto[];
  sections: ContractInstanceSectionDto[];
  signatureLines: ContractInstanceSignatureLineDto[];
  notes: string[];
  pdfAvailable: boolean;
  createdAt: Date;
  updatedAt: Date;
};

export function normalizeStoredGeneratedContractData(
  value: unknown,
): StoredGeneratedContractData {
  if (!isRecord(value)) {
    throw new DomainValidationError('Generated contract data is invalid.');
  }

  return {
    schemaVersion: normalizePositiveInteger(value.schemaVersion, 'schemaVersion'),
    documentTitle: normalizeNonEmptyString(value.documentTitle, 'documentTitle'),
    summary: normalizeNonEmptyString(value.summary, 'summary'),
    fileName: normalizeNonEmptyString(value.fileName, 'fileName'),
    values: normalizeValues(value.values),
    sections: normalizeSections(value.sections),
    signatureLines: normalizeSignatureLines(value.signatureLines),
    notes: normalizeStringArray(value.notes),
  };
}

function normalizeValues(value: unknown): ContractInstanceValueDto[] {
  if (!Array.isArray(value)) {
    throw new DomainValidationError('Generated contract values are invalid.');
  }

  return value.map((item, index) => {
    if (!isRecord(item)) {
      throw new DomainValidationError(`Generated contract value ${index} is invalid.`);
    }

    return {
      key: normalizeNonEmptyString(item.key, `values[${index}].key`),
      label: normalizeNonEmptyString(item.label, `values[${index}].label`),
      value: normalizeNonEmptyString(item.value, `values[${index}].value`),
    };
  });
}

function normalizeSections(value: unknown): ContractInstanceSectionDto[] {
  if (!Array.isArray(value) || value.length === 0) {
    throw new DomainValidationError('Generated contract sections are invalid.');
  }

  return value.map((item, index) => {
    if (!isRecord(item)) {
      throw new DomainValidationError(
        `Generated contract section ${index} is invalid.`,
      );
    }

    return {
      heading: normalizeNonEmptyString(item.heading, `sections[${index}].heading`),
      body: normalizeNonEmptyString(item.body, `sections[${index}].body`),
    };
  });
}

function normalizeSignatureLines(
  value: unknown,
): ContractInstanceSignatureLineDto[] {
  if (!Array.isArray(value)) {
    return [];
  }

  return value.map((item, index) => {
    if (!isRecord(item)) {
      throw new DomainValidationError(
        `Generated contract signature line ${index} is invalid.`,
      );
    }

    return {
      label: normalizeNonEmptyString(
        item.label,
        `signatureLines[${index}].label`,
      ),
      signerName: normalizeNonEmptyString(
        item.signerName,
        `signatureLines[${index}].signerName`,
      ),
    };
  });
}

function normalizeStringArray(value: unknown): string[] {
  if (!Array.isArray(value)) {
    return [];
  }

  return value.map((item, index) =>
    normalizeNonEmptyString(item, `notes[${index}]`),
  );
}

function normalizePositiveInteger(value: unknown, path: string): number {
  if (typeof value !== 'number' || !Number.isInteger(value) || value <= 0) {
    throw new DomainValidationError(`${path} must be a positive integer.`);
  }

  return value;
}

function normalizeNonEmptyString(value: unknown, path: string): string {
  if (typeof value !== 'string' || value.trim().length === 0) {
    throw new DomainValidationError(`${path} must be a non-empty string.`);
  }

  return value.trim();
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null && !Array.isArray(value);
}
