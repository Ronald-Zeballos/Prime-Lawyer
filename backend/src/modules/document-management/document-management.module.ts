import { Module } from '@nestjs/common';
import { CaseFilesModule } from '../case-files/case-files.module';
import { IdentityAccessModule } from '../identity-access/identity-access.module';
import { OcrProcessingModule } from '../ocr-processing/ocr-processing.module';
import { StorageManagementModule } from '../storage-management/storage-management.module';
import { GetDocumentFileUseCase } from './application/use-cases/get-document-file/get-document-file.use-case';
import { GetDocumentUseCase } from './application/use-cases/get-document/get-document.use-case';
import { ListCaseDocumentsUseCase } from './application/use-cases/list-case-documents/list-case-documents.use-case';
import {
  DOCUMENT_FILE_STORAGE,
} from './application/use-cases/register-document/document-file-storage.port';
import { RegisterDocumentUseCase } from './application/use-cases/register-document/register-document.use-case';
import { DOCUMENT_REPOSITORY } from './domain/repositories/document.repository';
import { LocalDocumentFileStorageAdapter } from './infrastructure/adapters/local-document-file-storage.adapter';
import { PrismaDocumentRepository } from './infrastructure/persistence/repositories/prisma-document.repository';
import { DocumentsController } from './presentation/controllers/documents.controller';

@Module({
  imports: [
    IdentityAccessModule,
    CaseFilesModule,
    StorageManagementModule,
    OcrProcessingModule,
  ],
  controllers: [DocumentsController],
  providers: [
    RegisterDocumentUseCase,
    GetDocumentFileUseCase,
    ListCaseDocumentsUseCase,
    GetDocumentUseCase,
    {
      provide: DOCUMENT_REPOSITORY,
      useClass: PrismaDocumentRepository,
    },
    {
      provide: DOCUMENT_FILE_STORAGE,
      useClass: LocalDocumentFileStorageAdapter,
    },
  ],
  exports: [DOCUMENT_REPOSITORY, DOCUMENT_FILE_STORAGE],
})
export class DocumentManagementModule {}
