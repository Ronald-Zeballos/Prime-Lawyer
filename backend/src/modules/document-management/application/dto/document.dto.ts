import { DocumentEntity } from '../../domain/entities/document.entity';

export type DocumentDto = {
  id: string;
  caseFileId: string;
  originalName: string;
  fileType: string;
  storagePath: string;
  hash: string;
  uploadSource: string;
  ocrStatus: string;
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
    ocrStatus: document.ocrStatus,
    uploadedById: document.uploadedById,
    uploadedAt: document.uploadedAt,
    createdAt: document.createdAt,
    updatedAt: document.updatedAt,
  };
}
