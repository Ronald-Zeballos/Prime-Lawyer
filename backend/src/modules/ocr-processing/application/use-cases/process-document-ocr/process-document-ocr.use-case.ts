import { Inject, Injectable } from '@nestjs/common';
import { OCRStatus as PrismaOCRStatus } from '@prisma/client';
import { NotFoundError } from '../../../../../shared/application/errors/not-found.error';
import { UseCase } from '../../../../../shared/application/use-case';
import { PrismaService } from '../../../../../shared/infrastructure/prisma/prisma.service';
import { RegisterAuditEventUseCase } from '../../../../audit-traceability/application/use-cases/register-audit-event/register-audit-event.use-case';
import { AuditEntityType } from '../../../../audit-traceability/domain/entities/audit-log.entity';
import {
  OBJECT_STORAGE,
  ObjectStorage,
} from '../../../../storage-management/infrastructure/adapters/object-storage.adapter';
import {
  OCR_PROVIDER,
  OcrProvider,
} from '../../../infrastructure/adapters/ocr-provider.adapter';

export type ProcessDocumentOcrCommand = {
  documentId: string;
  force?: boolean;
};

export type ProcessDocumentOcrResult = {
  documentId: string;
  ocrStatus: string;
  ocrText: string | null;
  ocrProcessedAt: Date | null;
};

@Injectable()
export class ProcessDocumentOcrUseCase
  implements UseCase<ProcessDocumentOcrCommand, ProcessDocumentOcrResult>
{
  constructor(
    private readonly prisma: PrismaService,
    @Inject(OBJECT_STORAGE)
    private readonly objectStorage: ObjectStorage,
    @Inject(OCR_PROVIDER)
    private readonly ocrProvider: OcrProvider,
    private readonly registerAuditEventUseCase: RegisterAuditEventUseCase,
  ) {}

  async execute(
    command: ProcessDocumentOcrCommand,
  ): Promise<ProcessDocumentOcrResult> {
    const existingDocument = await this.prisma.document.findUnique({
      where: { id: command.documentId },
    });

    if (!existingDocument) {
      throw new NotFoundError('Document was not found.');
    }

    if (
      !command.force &&
      existingDocument.ocrStatus === PrismaOCRStatus.COMPLETED &&
      existingDocument.ocrText
    ) {
      return this.toResult(existingDocument);
    }

    const processingAt = new Date();

    await this.prisma.document.update({
      where: { id: existingDocument.id },
      data: {
        ocrStatus: PrismaOCRStatus.PROCESSING,
        ocrProcessedAt: processingAt,
        updatedAt: processingAt,
      },
    });

    try {
      const storedFile = await this.objectStorage.read({
        storagePath: existingDocument.storagePath,
      });
      const extraction = await this.ocrProvider.extractText({
        originalName: existingDocument.originalName,
        fileType: existingDocument.fileType,
        uploadSource: existingDocument.uploadSource,
        storagePath: existingDocument.storagePath,
        hash: existingDocument.hash,
        buffer: storedFile.buffer,
      });
      const processedAt = new Date();
      const updatedDocument = await this.prisma.document.update({
        where: { id: existingDocument.id },
        data: {
          ocrStatus: PrismaOCRStatus.COMPLETED,
          ocrText: extraction.text,
          ocrProcessedAt: processedAt,
          updatedAt: processedAt,
        },
      });

      await this.registerAuditEventUseCase.execute({
        entityType: AuditEntityType.DOCUMENT,
        entityId: existingDocument.id,
        caseFileId: existingDocument.caseFileId,
        action: 'DOCUMENT_OCR_PROCESSED',
        performedById: existingDocument.uploadedById,
        metadata: {
          provider: extraction.provider,
          mode: extraction.mode,
          confidence: extraction.confidence,
          textLength: extraction.text.length,
        },
      });

      return this.toResult(updatedDocument);
    } catch (error) {
      const failedAt = new Date();
      const failedDocument = await this.prisma.document.update({
        where: { id: existingDocument.id },
        data: {
          ocrStatus: PrismaOCRStatus.FAILED,
          ocrText: null,
          ocrProcessedAt: failedAt,
          updatedAt: failedAt,
        },
      });

      await this.registerAuditEventUseCase.execute({
        entityType: AuditEntityType.DOCUMENT,
        entityId: existingDocument.id,
        caseFileId: existingDocument.caseFileId,
        action: 'DOCUMENT_OCR_FAILED',
        performedById: existingDocument.uploadedById,
        metadata: {
          reason: error instanceof Error ? error.message : 'Unknown OCR error',
        },
      });

      return this.toResult(failedDocument);
    }
  }

  private toResult(document: {
    id: string;
    ocrStatus: PrismaOCRStatus;
    ocrText: string | null;
    ocrProcessedAt: Date | null;
  }): ProcessDocumentOcrResult {
    return {
      documentId: document.id,
      ocrStatus: document.ocrStatus,
      ocrText: document.ocrText,
      ocrProcessedAt: document.ocrProcessedAt,
    };
  }
}
