import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import envConfig from './config/env.config';
import databaseConfig from './config/database.config';
import authConfig from './config/auth.config';
import storageConfig from './config/storage.config';
import { AuditTraceabilityModule } from './modules/audit-traceability/audit-traceability.module';
import { CaseFilesModule } from './modules/case-files/case-files.module';
import { ClientsModule } from './modules/clients/clients.module';
import { DocumentManagementModule } from './modules/document-management/document-management.module';
import { IdentityAccessModule } from './modules/identity-access/identity-access.module';
import { PrismaModule } from './shared/infrastructure/prisma/prisma.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      load: [envConfig, databaseConfig, authConfig, storageConfig],
      envFilePath: '.env',
    }),
    PrismaModule,
    AuditTraceabilityModule,
    IdentityAccessModule,
    ClientsModule,
    CaseFilesModule,
    DocumentManagementModule,
  ],
})
export class AppModule {}
