import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import envConfig from './config/env.config';
import databaseConfig from './config/database.config';
import authConfig from './config/auth.config';
import storageConfig from './config/storage.config';
import { HealthController } from './health.controller';
import { AuditTraceabilityModule } from './modules/audit-traceability/audit-traceability.module';
import { CaseFilesModule } from './modules/case-files/case-files.module';
import { ClientsModule } from './modules/clients/clients.module';
import { ContractMarketplaceModule } from './modules/contract-marketplace/contract-marketplace.module';
import { DocumentManagementModule } from './modules/document-management/document-management.module';
import { IdentityAccessModule } from './modules/identity-access/identity-access.module';
import { LegalAiModule } from './modules/legal-ai/legal-ai.module';
import { OcrProcessingModule } from './modules/ocr-processing/ocr-processing.module';
import { PaymentsModule } from './modules/payments/payments.module';
import { SemanticSearchModule } from './modules/semantic-search/semantic-search.module';
import { StorageManagementModule } from './modules/storage-management/storage-management.module';
import { SubscriptionModule } from './modules/subscription/subscription.module';
import { UserProfileModule } from './modules/user-profile/user-profile.module';
import { PrismaModule } from './shared/infrastructure/prisma/prisma.module';

@Module({
  controllers: [HealthController],
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      load: [envConfig, databaseConfig, authConfig, storageConfig],
      envFilePath: '.env',
    }),
    PrismaModule,
    AuditTraceabilityModule,
    IdentityAccessModule,
    UserProfileModule,
    ClientsModule,
    CaseFilesModule,
    DocumentManagementModule,
    StorageManagementModule,
    OcrProcessingModule,
    SemanticSearchModule,
    LegalAiModule,
    ContractMarketplaceModule,
    PaymentsModule,
    SubscriptionModule,
  ],
})
export class AppModule {}
