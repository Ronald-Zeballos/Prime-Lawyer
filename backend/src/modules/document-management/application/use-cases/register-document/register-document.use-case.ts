import { randomUUID } from 'node:crypto';
import { Inject, Injectable } from '@nestjs/common';
import { NotFoundError } from '../../../../../shared/application/errors/not-found.error';
import { UseCase } from '../../../../../shared/application/use-case';
import {
  AuditEntityType,
} from '../../../../audit-traceability/domain/entities/audit-log.entity';
import { RegisterAuditEventUseCase } from '../../../../audit-traceability/application/use-cases/register-audit-event/register-audit-event.use-case';
import {
  CASE_FILE_REPOSITORY,
  CaseFileRepository,
} from '../../../../case-files/domain/repositories/case-file.repository';
import { CaseFileId } from '../../../../case-files/domain/value-objects/case-file-id.vo';
import {
  USER_REPOSITORY,
  UserRepository,
} from '../../../../identity-access/domain/repositories/user.repository';
import { UserId } from '../../../../identity-access/domain/value-objects/user-id.vo';
import { DocumentEntity, OCRStatus } from '../../../domain/entities/document.entity';
import {
  DOCUMENT_REPOSITORY,
  DocumentRepository,
} from '../../../domain/repositories/document.repository';
import { DocumentDto, toDocumentDto } from '../../dto/document.dto';
import {
  DOCUMENT_FILE_STORAGE,
  DocumentFileStorage,
} from './document-file-storage.port';

export type RegisterDocumentCommand = {
  caseFileId: string;
  originalName: string;
  fileType: string;
  uploadSource: string;
  uploadedById: string;
  fileBuffer: Buffer;
};

@Injectable()
export class RegisterDocumentUseCase
  implements UseCase<RegisterDocumentCommand, DocumentDto>
{
  constructor(
    @Inject(DOCUMENT_REPOSITORY)
    private readonly documentRepository: DocumentRepository,
    @Inject(CASE_FILE_REPOSITORY)
    private readonly caseFileRepository: CaseFileRepository,
    @Inject(USER_REPOSITORY)
    private readonly userRepository: UserRepository,
    @Inject(DOCUMENT_FILE_STORAGE)
    private readonly documentFileStorage: DocumentFileStorage,
    private readonly registerAuditEventUseCase: RegisterAuditEventUseCase,
  ) {}

  async execute(command: RegisterDocumentCommand): Promise<DocumentDto> {
    const caseFile = await this.caseFileRepository.findById(
      CaseFileId.create(command.caseFileId),
    );

    if (!caseFile) {
      throw new NotFoundError('Case file was not found.');
    }

    const uploadedByUser = await this.userRepository.findById(
      UserId.create(command.uploadedById),
    );

    if (!uploadedByUser) {
      throw new NotFoundError('Uploading user was not found.');
    }

    const storedFile = await this.documentFileStorage.store({
      caseFileId: command.caseFileId,
      originalName: command.originalName,
      buffer: command.fileBuffer,
    });

    const now = new Date();
    const document = DocumentEntity.create({
      id: randomUUID(),
      caseFileId: command.caseFileId,
      originalName: command.originalName,
      fileType: command.fileType,
      storagePath: storedFile.storagePath,
      hash: storedFile.hash,
      uploadSource: command.uploadSource,
      ocrStatus: OCRStatus.PENDING,
      uploadedById: command.uploadedById,
      uploadedAt: now,
      createdAt: now,
      updatedAt: now,
    });

    const createdDocument = await this.documentRepository.create(document);

    await this.registerAuditEventUseCase.execute({
      entityType: AuditEntityType.DOCUMENT,
      entityId: createdDocument.id.value,
      caseFileId: createdDocument.caseFileId,
      action: 'DOCUMENT_REGISTERED',
      performedById: createdDocument.uploadedById,
      metadata: {
        originalName: createdDocument.originalName,
        fileType: createdDocument.fileType.value,
        uploadSource: createdDocument.uploadSource,
        ocrStatus: createdDocument.ocrStatus,
      },
    });

    return toDocumentDto(createdDocument);
  }
}
