import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../../../../../shared/infrastructure/prisma/prisma.service';
import { CaseFileEntity } from '../../../domain/entities/case-file.entity';
import {
  CaseFileRepository,
  SearchCaseFilesFilters,
} from '../../../domain/repositories/case-file.repository';
import { CaseFileId } from '../../../domain/value-objects/case-file-id.vo';
import { CaseStatusValue } from '../../../domain/value-objects/case-status.vo';
import { CaseFilePrismaMapper } from '../mappers/case-file-prisma.mapper';

@Injectable()
export class PrismaCaseFileRepository implements CaseFileRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findById(id: CaseFileId): Promise<CaseFileEntity | null> {
    const caseFile = await this.prisma.caseFile.findUnique({
      where: { id: id.value },
    });

    return caseFile ? CaseFilePrismaMapper.toDomain(caseFile) : null;
  }

  async findByInternalCode(internalCode: string): Promise<CaseFileEntity | null> {
    const caseFile = await this.prisma.caseFile.findUnique({
      where: { internalCode },
    });

    return caseFile ? CaseFilePrismaMapper.toDomain(caseFile) : null;
  }

  async search(filters?: SearchCaseFilesFilters): Promise<CaseFileEntity[]> {
    const normalizedTerm = filters?.term?.trim();
    const where: Prisma.CaseFileWhereInput = {
      ...(filters?.ownerUserId
        ? { ownerUserId: filters.ownerUserId.trim() }
        : {}),
      ...(filters?.status
        ? { status: CaseStatusValue.create(filters.status).value }
        : {}),
      ...(filters?.responsibleUserId
        ? { responsibleUserId: filters.responsibleUserId.trim() }
        : {}),
      ...(normalizedTerm
        ? {
            OR: [
              {
                internalCode: {
                  contains: normalizedTerm,
                  mode: 'insensitive',
                },
              },
              {
                title: {
                  contains: normalizedTerm,
                  mode: 'insensitive',
                },
              },
              {
                description: {
                  contains: normalizedTerm,
                  mode: 'insensitive',
                },
              },
              {
                processType: {
                  contains: normalizedTerm,
                  mode: 'insensitive',
                },
              },
              {
                searchText: {
                  contains: normalizedTerm,
                  mode: 'insensitive',
                },
              },
            ],
          }
        : {}),
    };

    const caseFiles = await this.prisma.caseFile.findMany({
      where,
      orderBy: [{ createdAt: 'desc' }],
    });

    return caseFiles.map((caseFile) => CaseFilePrismaMapper.toDomain(caseFile));
  }

  async create(caseFile: CaseFileEntity): Promise<CaseFileEntity> {
    const createdCaseFile = await this.prisma.caseFile.create({
      data: {
        id: caseFile.id.value,
        internalCode: caseFile.internalCode,
        clientId: null,
        ownerUserId: caseFile.ownerUserId,
        title: caseFile.title,
        subject: caseFile.title,
        description: caseFile.description,
        processType: caseFile.processType,
        status: caseFile.status.value,
        responsibleUserId: caseFile.responsibleUserId,
        openedAt: caseFile.openedAt,
        closedAt: caseFile.closedAt,
        visibility: caseFile.visibility,
        knowledgeStatus: caseFile.knowledgeStatus,
        searchText: caseFile.searchText,
        confidentialityLevel: caseFile.confidentialityLevel.value,
        createdAt: caseFile.createdAt,
        updatedAt: caseFile.updatedAt,
      },
    });

    return CaseFilePrismaMapper.toDomain(createdCaseFile);
  }

  async update(caseFile: CaseFileEntity): Promise<CaseFileEntity> {
    const updatedCaseFile = await this.prisma.caseFile.update({
      where: { id: caseFile.id.value },
      data: {
        internalCode: caseFile.internalCode,
        ownerUserId: caseFile.ownerUserId,
        title: caseFile.title,
        subject: caseFile.title,
        description: caseFile.description,
        processType: caseFile.processType,
        status: caseFile.status.value,
        responsibleUserId: caseFile.responsibleUserId,
        openedAt: caseFile.openedAt,
        closedAt: caseFile.closedAt,
        visibility: caseFile.visibility,
        knowledgeStatus: caseFile.knowledgeStatus,
        searchText: caseFile.searchText,
        confidentialityLevel: caseFile.confidentialityLevel.value,
        updatedAt: caseFile.updatedAt,
      },
    });

    return CaseFilePrismaMapper.toDomain(updatedCaseFile);
  }
}
