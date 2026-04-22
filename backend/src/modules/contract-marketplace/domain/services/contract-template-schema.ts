import { DomainValidationError } from '../../../../shared/domain/errors/domain-validation.error';

export type ContractTemplateFieldType =
  | 'text'
  | 'textarea'
  | 'number'
  | 'date'
  | 'select'
  | 'boolean';

export type ContractTemplateFieldOption = {
  value: string;
  label: string;
};

export type ContractTemplateFieldSchema = {
  key: string;
  type: ContractTemplateFieldType;
  label: string;
  placeholder: string | null;
  helperText: string | null;
  group: string | null;
  required: boolean;
  defaultValue: string | number | boolean | null;
  options: ContractTemplateFieldOption[];
};

export type ContractTemplateSectionSchema = {
  heading: string;
  body: string;
};

export type ContractTemplateSignatureLineSchema = {
  label: string;
  valueKey: string;
};

export type ContractTemplateSchema = {
  version: number;
  category: string;
  documentTitle: string;
  summary: string;
  fields: ContractTemplateFieldSchema[];
  sections: ContractTemplateSectionSchema[];
  signatureLines: ContractTemplateSignatureLineSchema[];
  notes: string[];
};

const SUPPORTED_FIELD_TYPES: ContractTemplateFieldType[] = [
  'text',
  'textarea',
  'number',
  'date',
  'select',
  'boolean',
];

export function normalizeContractTemplateSchema(
  input: unknown,
): ContractTemplateSchema {
  if (!isRecord(input)) {
    throw new DomainValidationError('Contract template schema must be an object.');
  }

  const version = normalizePositiveInteger(input.version, 'version');
  const category = normalizeNonEmptyString(input.category, 'category');
  const documentTitle = normalizeNonEmptyString(
    input.documentTitle,
    'documentTitle',
  );
  const summary = normalizeNonEmptyString(input.summary, 'summary');
  const fields = normalizeFields(input.fields);
  const sections = normalizeSections(input.sections);
  const signatureLines = normalizeSignatureLines(input.signatureLines);
  const notes = normalizeStringArray(input.notes, 'notes');

  return {
    version,
    category,
    documentTitle,
    summary,
    fields,
    sections,
    signatureLines,
    notes,
  };
}

function normalizeFields(value: unknown): ContractTemplateFieldSchema[] {
  if (!Array.isArray(value) || value.length === 0) {
    throw new DomainValidationError(
      'Contract template schema must define at least one field.',
    );
  }

  return value.map((item, index) => {
    if (!isRecord(item)) {
      throw new DomainValidationError(
        `Contract template field at index ${index} is invalid.`,
      );
    }

    const key = normalizeNonEmptyString(item.key, `fields[${index}].key`);
    const type = normalizeFieldType(item.type, `fields[${index}].type`);
    const label = normalizeNonEmptyString(item.label, `fields[${index}].label`);
    const required = typeof item.required === 'boolean' ? item.required : false;
    const options = type === 'select'
      ? normalizeFieldOptions(item.options, `fields[${index}].options`)
      : [];

    if (type === 'select' && options.length === 0) {
      throw new DomainValidationError(
        `Contract template field ${key} must define select options.`,
      );
    }

    return {
      key,
      type,
      label,
      placeholder: normalizeNullableString(item.placeholder),
      helperText: normalizeNullableString(item.helperText),
      group: normalizeNullableString(item.group),
      required,
      defaultValue: normalizeDefaultValue(item.defaultValue, type, key),
      options,
    };
  });
}

function normalizeSections(value: unknown): ContractTemplateSectionSchema[] {
  if (!Array.isArray(value) || value.length === 0) {
    throw new DomainValidationError(
      'Contract template schema must define at least one section.',
    );
  }

  return value.map((item, index) => {
    if (!isRecord(item)) {
      throw new DomainValidationError(
        `Contract template section at index ${index} is invalid.`,
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
): ContractTemplateSignatureLineSchema[] {
  if (!Array.isArray(value)) {
    return [];
  }

  return value.map((item, index) => {
    if (!isRecord(item)) {
      throw new DomainValidationError(
        `Contract template signature line at index ${index} is invalid.`,
      );
    }

    return {
      label: normalizeNonEmptyString(
        item.label,
        `signatureLines[${index}].label`,
      ),
      valueKey: normalizeNonEmptyString(
        item.valueKey,
        `signatureLines[${index}].valueKey`,
      ),
    };
  });
}

function normalizeFieldOptions(
  value: unknown,
  path: string,
): ContractTemplateFieldOption[] {
  if (!Array.isArray(value)) {
    return [];
  }

  return value.map((item, index) => {
    if (!isRecord(item)) {
      throw new DomainValidationError(`${path}[${index}] must be an object.`);
    }

    return {
      value: normalizeNonEmptyString(item.value, `${path}[${index}].value`),
      label: normalizeNonEmptyString(item.label, `${path}[${index}].label`),
    };
  });
}

function normalizeDefaultValue(
  value: unknown,
  type: ContractTemplateFieldType,
  key: string,
): string | number | boolean | null {
  if (value == null) {
    return null;
  }

  switch (type) {
    case 'boolean':
      if (typeof value !== 'boolean') {
        throw new DomainValidationError(
          `Contract template field ${key} must use a boolean default value.`,
        );
      }

      return value;
    case 'number':
      if (typeof value !== 'number' || Number.isNaN(value)) {
        throw new DomainValidationError(
          `Contract template field ${key} must use a numeric default value.`,
        );
      }

      return value;
    default: {
      if (typeof value !== 'string') {
        throw new DomainValidationError(
          `Contract template field ${key} must use a string default value.`,
        );
      }

      return value.trim();
    }
  }
}

function normalizeFieldType(
  value: unknown,
  path: string,
): ContractTemplateFieldType {
  const normalizedValue = normalizeNonEmptyString(value, path).toLowerCase();

  if (
    !SUPPORTED_FIELD_TYPES.includes(normalizedValue as ContractTemplateFieldType)
  ) {
    throw new DomainValidationError(`Unsupported field type at ${path}.`);
  }

  return normalizedValue as ContractTemplateFieldType;
}

function normalizeStringArray(value: unknown, path: string): string[] {
  if (!Array.isArray(value)) {
    return [];
  }

  return value.map((item, index) =>
    normalizeNonEmptyString(item, `${path}[${index}]`),
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

function normalizeNullableString(value: unknown): string | null {
  if (typeof value !== 'string') {
    return null;
  }

  const normalizedValue = value.trim();
  return normalizedValue.length > 0 ? normalizedValue : null;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null && !Array.isArray(value);
}
