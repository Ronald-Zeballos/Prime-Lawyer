import { Module } from '@nestjs/common';
import { IdentityAccessModule } from '../identity-access/identity-access.module';
import { StorageManagementModule } from '../storage-management/storage-management.module';
import { GenerateContractFromTemplateUseCase } from './application/use-cases/generate-contract-from-template/generate-contract-from-template.use-case';
import {
  CONTRACT_PDF_STORAGE,
} from './application/use-cases/generate-contract-from-template/contract-pdf-storage.port';
import { GetContractTemplateUseCase } from './application/use-cases/get-contract-template/get-contract-template.use-case';
import { GetContractInstancePdfUseCase } from './application/use-cases/get-contract-instance-pdf/get-contract-instance-pdf.use-case';
import { ListActiveContractTemplatesUseCase } from './application/use-cases/list-active-contract-templates/list-active-contract-templates.use-case';
import { ListUserContractInstancesUseCase } from './application/use-cases/list-user-contract-instances/list-user-contract-instances.use-case';
import { LocalContractPdfStorageAdapter } from './infrastructure/adapters/local-contract-pdf-storage.adapter';
import { ContractPdfBuilderService } from './infrastructure/services/contract-pdf-builder.service';
import { ContractMarketplaceController } from './presentation/controllers/contract-marketplace.controller';

@Module({
  imports: [IdentityAccessModule, StorageManagementModule],
  controllers: [ContractMarketplaceController],
  providers: [
    ListActiveContractTemplatesUseCase,
    GetContractTemplateUseCase,
    GenerateContractFromTemplateUseCase,
    ListUserContractInstancesUseCase,
    GetContractInstancePdfUseCase,
    ContractPdfBuilderService,
    {
      provide: CONTRACT_PDF_STORAGE,
      useClass: LocalContractPdfStorageAdapter,
    },
  ],
})
export class ContractMarketplaceModule {}
