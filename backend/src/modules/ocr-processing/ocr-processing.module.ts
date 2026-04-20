import { Module } from '@nestjs/common';
import { StorageManagementModule } from '../storage-management/storage-management.module';
import { ProcessDocumentOcrUseCase } from './application/use-cases/process-document-ocr/process-document-ocr.use-case';
import {
  OCR_PROVIDER,
} from './infrastructure/adapters/ocr-provider.adapter';
import { HeuristicOcrProviderAdapter } from './infrastructure/adapters/heuristic-ocr-provider.adapter';

@Module({
  imports: [StorageManagementModule],
  providers: [
    ProcessDocumentOcrUseCase,
    {
      provide: OCR_PROVIDER,
      useClass: HeuristicOcrProviderAdapter,
    },
  ],
  exports: [ProcessDocumentOcrUseCase],
})
export class OcrProcessingModule {}
