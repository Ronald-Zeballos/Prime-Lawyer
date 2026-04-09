import { Document as PrismaDocumentModel, OCRStatus as PrismaOCRStatus } from '@prisma/client';
import { DocumentEntity, OCRStatus } from '../../../domain/entities/document.entity';

export class DocumentPrismaMapper {
  static toDomain(document: PrismaDocumentModel): DocumentEntity {
    return DocumentEntity.create({
      id: document.id,
      caseFileId: document.caseFileId,
      originalName: document.originalName,
      fileType: document.fileType,
      storagePath: document.storagePath,
      hash: document.hash,
      uploadSource: document.uploadSource,
      ocrStatus: this.toOcrStatus(document.ocrStatus),
      uploadedById: document.uploadedById,
      uploadedAt: document.uploadedAt,
      createdAt: document.createdAt,
      updatedAt: document.updatedAt,
    });
  }

  private static toOcrStatus(ocrStatus: PrismaOCRStatus): OCRStatus {
    switch (ocrStatus) {
      case PrismaOCRStatus.PENDING:
        return OCRStatus.PENDING;
      case PrismaOCRStatus.COMPLETED:
        return OCRStatus.COMPLETED;
      case PrismaOCRStatus.FAILED:
        return OCRStatus.FAILED;
      default:
        throw new Error(`Unsupported OCR status: ${ocrStatus}`);
    }
  }
}
