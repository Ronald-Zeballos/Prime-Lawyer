import { DocumentEntity } from '../../domain/entities/document.entity';

export type DocumentDto = {
  id: string;
  caseFileId: string;
  originalName: string;
  fileType: string;
  storagePath: string;
  hash: string;
  uploadSource: string;
  source: string;
  pageCount: number | null;
  fileSizeBytes: number | null;
  ocrStatus: string;
  ocrText: string | null;
  ocrProcessedAt: Date | null;
  uploadedById: string;
  uploadedAt: Date;
  createdAt: Date;
  updatedAt: Date;
};

export function toDocumentDto(document: DocumentEntity): DocumentDto {
  return {
    id: document.id.value,
    caseFileId: document.caseFileId,
    originalName: document.originalName,
    fileType: document.fileType.value,
    storagePath: document.storagePath,
    hash: document.hash.value,
    uploadSource: document.uploadSource,
    source: document.source,
    pageCount: document.pageCount,
    fileSizeBytes: document.fileSizeBytes,
    ocrStatus: document.ocrStatus,
    ocrText: document.ocrText,
    ocrProcessedAt: document.ocrProcessedAt,
    uploadedById: document.uploadedById,
    uploadedAt: document.uploadedAt,
    createdAt: document.createdAt,
    updatedAt: document.updatedAt,
  };
}
