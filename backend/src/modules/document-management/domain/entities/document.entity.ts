import { BaseEntity } from '../../../../shared/domain/base-entity';
import { DomainValidationError } from '../../../../shared/domain/errors/domain-validation.error';
import { DocumentId } from '../value-objects/document-id.vo';
import { FileHash } from '../value-objects/file-hash.vo';
import { MimeType } from '../value-objects/mime-type.vo';

export enum OCRStatus {
  PENDING = 'PENDING',
  PROCESSING = 'PROCESSING',
  COMPLETED = 'COMPLETED',
  FAILED = 'FAILED',
}

export enum DocumentSource {
  CAMERA = 'CAMERA',
  GALLERY = 'GALLERY',
  FILE_UPLOAD = 'FILE_UPLOAD',
}

type DocumentEntityProps = {
  caseFileId: string;
  originalName: string;
  fileType: MimeType;
  storagePath: string;
  hash: FileHash;
  uploadSource: string;
  source: DocumentSource;
  pageCount: number | null;
  fileSizeBytes: number | null;
  ocrStatus: OCRStatus;
  ocrText: string | null;
  ocrProcessedAt: Date | null;
  uploadedById: string;
  uploadedAt: Date;
  createdAt: Date;
  updatedAt: Date;
};

type CreateDocumentEntityProps = {
  id: string;
  caseFileId: string;
  originalName: string;
  fileType: string;
  storagePath: string;
  hash: string;
  uploadSource: string;
  source?: string;
  pageCount?: number | null;
  fileSizeBytes?: number | null;
  ocrStatus?: string;
  ocrText?: string | null;
  ocrProcessedAt?: Date | null;
  uploadedById: string;
  uploadedAt: Date;
  createdAt: Date;
  updatedAt: Date;
};

export class DocumentEntity extends BaseEntity<DocumentId> {
  private constructor(id: DocumentId, private readonly props: DocumentEntityProps) {
    super(id);
  }

  static create(props: CreateDocumentEntityProps): DocumentEntity {
    return new DocumentEntity(DocumentId.create(props.id), {
      caseFileId: this.normalizeRequiredText(props.caseFileId, 'Case file id'),
      originalName: this.normalizeRequiredText(props.originalName, 'Original name'),
      fileType: MimeType.create(props.fileType),
      storagePath: this.normalizeRequiredText(props.storagePath, 'Storage path'),
      hash: FileHash.create(props.hash),
      uploadSource: this.normalizeRequiredText(props.uploadSource, 'Upload source'),
      source: this.normalizeSource(props.source ?? DocumentSource.FILE_UPLOAD),
      pageCount: this.normalizeOptionalPositiveInt(props.pageCount, 'Page count'),
      fileSizeBytes: this.normalizeOptionalPositiveInt(
        props.fileSizeBytes,
        'File size',
        0,
      ),
      ocrStatus: this.normalizeOcrStatus(props.ocrStatus ?? OCRStatus.PENDING),
      ocrText: this.normalizeOptionalText(props.ocrText),
      ocrProcessedAt: props.ocrProcessedAt ?? null,
      uploadedById: this.normalizeRequiredText(props.uploadedById, 'Uploaded by'),
      uploadedAt: props.uploadedAt,
      createdAt: props.createdAt,
      updatedAt: props.updatedAt,
    });
  }

  get caseFileId(): string {
    return this.props.caseFileId;
  }

  get originalName(): string {
    return this.props.originalName;
  }

  get fileType(): MimeType {
    return this.props.fileType;
  }

  get storagePath(): string {
    return this.props.storagePath;
  }

  get hash(): FileHash {
    return this.props.hash;
  }

  get uploadSource(): string {
    return this.props.uploadSource;
  }

  get source(): DocumentSource {
    return this.props.source;
  }

  get pageCount(): number | null {
    return this.props.pageCount;
  }

  get fileSizeBytes(): number | null {
    return this.props.fileSizeBytes;
  }

  get ocrStatus(): OCRStatus {
    return this.props.ocrStatus;
  }

  get ocrText(): string | null {
    return this.props.ocrText;
  }

  get ocrProcessedAt(): Date | null {
    return this.props.ocrProcessedAt;
  }

  get uploadedById(): string {
    return this.props.uploadedById;
  }

  get uploadedAt(): Date {
    return this.props.uploadedAt;
  }

  get createdAt(): Date {
    return this.props.createdAt;
  }

  get updatedAt(): Date {
    return this.props.updatedAt;
  }

  withOcrProcessingStarted(processedAt: Date): DocumentEntity {
    return new DocumentEntity(this.id, {
      ...this.props,
      ocrStatus: OCRStatus.PROCESSING,
      ocrProcessedAt: processedAt,
      updatedAt: processedAt,
    });
  }

  withCompletedOcr(ocrText: string, processedAt: Date): DocumentEntity {
    return new DocumentEntity(this.id, {
      ...this.props,
      ocrStatus: OCRStatus.COMPLETED,
      ocrText: DocumentEntity.normalizeOptionalText(ocrText),
      ocrProcessedAt: processedAt,
      updatedAt: processedAt,
    });
  }

  withFailedOcr(processedAt: Date): DocumentEntity {
    return new DocumentEntity(this.id, {
      ...this.props,
      ocrStatus: OCRStatus.FAILED,
      ocrText: null,
      ocrProcessedAt: processedAt,
      updatedAt: processedAt,
    });
  }

  private static normalizeRequiredText(value: string, fieldName: string): string {
    const normalizedValue = value.trim();

    if (!normalizedValue) {
      throw new DomainValidationError(`${fieldName} is required.`);
    }

    return normalizedValue;
  }

  private static normalizeOptionalText(value?: string | null): string | null {
    const normalizedValue = value?.trim();

    if (!normalizedValue) {
      return null;
    }

    return normalizedValue;
  }

  private static normalizeOcrStatus(value: string): OCRStatus {
    const normalizedValue = value.trim().toUpperCase() as OCRStatus;

    if (!Object.values(OCRStatus).includes(normalizedValue)) {
      throw new DomainValidationError('OCR status is invalid.');
    }

    return normalizedValue;
  }

  private static normalizeSource(value: string): DocumentSource {
    const normalizedValue = value.trim().toUpperCase() as DocumentSource;

    if (!Object.values(DocumentSource).includes(normalizedValue)) {
      throw new DomainValidationError('Document source is invalid.');
    }

    return normalizedValue;
  }

  private static normalizeOptionalPositiveInt(
    value: number | null | undefined,
    fieldName: string,
    minimum = 1,
  ): number | null {
    if (value == null) {
      return null;
    }

    const normalizedValue = Math.trunc(value);

    if (normalizedValue < minimum) {
      throw new DomainValidationError(`${fieldName} is invalid.`);
    }

    return normalizedValue;
  }
}
