import { Global, Module } from '@nestjs/common';
import { IdentityAccessModule } from '../identity-access/identity-access.module';
import { AuditLogsController } from './presentation/controllers/audit-logs.controller';
import { GetCaseHistoryUseCase } from './application/use-cases/get-case-history/get-case-history.use-case';
import { GetEntityHistoryUseCase } from './application/use-cases/get-entity-history/get-entity-history.use-case';
import { RegisterAuditEventUseCase } from './application/use-cases/register-audit-event/register-audit-event.use-case';
import { AUDIT_LOG_REPOSITORY } from './domain/repositories/audit-log.repository';
import { PrismaAuditLogRepository } from './infrastructure/persistence/repositories/prisma-audit-log.repository';

@Global()
@Module({
  imports: [IdentityAccessModule],
  controllers: [AuditLogsController],
  providers: [
    RegisterAuditEventUseCase,
    GetCaseHistoryUseCase,
    GetEntityHistoryUseCase,
    {
      provide: AUDIT_LOG_REPOSITORY,
      useClass: PrismaAuditLogRepository,
    },
  ],
  exports: [RegisterAuditEventUseCase],
})
export class AuditTraceabilityModule {}
