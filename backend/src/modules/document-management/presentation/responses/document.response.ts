import { DocumentDto } from '../../application/dto/document.dto';

export class DocumentResponse {
  id!: string;
  caseFileId!: string;
  originalName!: string;
  fileType!: string;
  storagePath!: string;
  hash!: string;
  uploadSource!: string;
  ocrStatus!: string;
  uploadedById!: string;
  uploadedAt!: Date;
  createdAt!: Date;
  updatedAt!: Date;

  static fromDto(dto: DocumentDto): DocumentResponse {
    return {
      id: dto.id,
      caseFileId: dto.caseFileId,
      originalName: dto.originalName,
      fileType: dto.fileType,
      storagePath: dto.storagePath,
      hash: dto.hash,
      uploadSource: dto.uploadSource,
      ocrStatus: dto.ocrStatus,
      uploadedById: dto.uploadedById,
      uploadedAt: dto.uploadedAt,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    };
  }
}
