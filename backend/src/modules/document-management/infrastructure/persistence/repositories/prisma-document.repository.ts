import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../../../shared/infrastructure/prisma/prisma.service';
import { DocumentEntity } from '../../../domain/entities/document.entity';
import { DocumentRepository } from '../../../domain/repositories/document.repository';
import { DocumentId } from '../../../domain/value-objects/document-id.vo';
import { DocumentPrismaMapper } from '../mappers/document-prisma.mapper';

@Injectable()
export class PrismaDocumentRepository implements DocumentRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findById(id: DocumentId): Promise<DocumentEntity | null> {
    const document = await this.prisma.document.findUnique({
      where: { id: id.value },
    });

    return document ? DocumentPrismaMapper.toDomain(document) : null;
  }

  async findByCaseFileId(caseFileId: string): Promise<DocumentEntity[]> {
    const documents = await this.prisma.document.findMany({
      where: { caseFileId: caseFileId.trim() },
      orderBy: [{ uploadedAt: 'desc' }],
    });

    return documents.map((document) => DocumentPrismaMapper.toDomain(document));
  }

  async create(document: DocumentEntity): Promise<DocumentEntity> {
    const createdDocument = await this.prisma.document.create({
      data: {
        id: document.id.value,
        caseFileId: document.caseFileId,
        originalName: document.originalName,
        fileType: document.fileType.value,
        storagePath: document.storagePath,
        hash: document.hash.value,
        uploadSource: document.uploadSource,
        ocrStatus: document.ocrStatus,
        ocrText: document.ocrText,
        ocrProcessedAt: document.ocrProcessedAt,
        uploadedById: document.uploadedById,
        uploadedAt: document.uploadedAt,
        createdAt: document.createdAt,
        updatedAt: document.updatedAt,
      },
    });

    return DocumentPrismaMapper.toDomain(createdDocument);
  }

  async update(document: DocumentEntity): Promise<DocumentEntity> {
    const updatedDocument = await this.prisma.document.update({
      where: { id: document.id.value },
      data: {
        caseFileId: document.caseFileId,
        originalName: document.originalName,
        fileType: document.fileType.value,
        storagePath: document.storagePath,
        hash: document.hash.value,
        uploadSource: document.uploadSource,
        ocrStatus: document.ocrStatus,
        ocrText: document.ocrText,
        ocrProcessedAt: document.ocrProcessedAt,
        uploadedById: document.uploadedById,
        uploadedAt: document.uploadedAt,
        createdAt: document.createdAt,
        updatedAt: document.updatedAt,
      },
    });

    return DocumentPrismaMapper.toDomain(updatedDocument);
  }
}
