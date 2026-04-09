import { Module } from '@nestjs/common';
import { ClientsModule } from '../clients/clients.module';
import { IdentityAccessModule } from '../identity-access/identity-access.module';
import { CreateCaseFileUseCase } from './application/use-cases/create-case-file/create-case-file.use-case';
import { GetCaseFileUseCase } from './application/use-cases/get-case-file/get-case-file.use-case';
import { SearchCaseFilesUseCase } from './application/use-cases/search-case-files/search-case-files.use-case';
import { ChangeCaseStatusUseCase } from './application/use-cases/change-case-status/change-case-status.use-case';
import { CASE_FILE_REPOSITORY } from './domain/repositories/case-file.repository';
import { PrismaCaseFileRepository } from './infrastructure/persistence/repositories/prisma-case-file.repository';
import { CaseFilesController } from './presentation/controllers/case-files.controller';

@Module({
  imports: [IdentityAccessModule, ClientsModule],
  controllers: [CaseFilesController],
  providers: [
    CreateCaseFileUseCase,
    GetCaseFileUseCase,
    SearchCaseFilesUseCase,
    ChangeCaseStatusUseCase,
    {
      provide: CASE_FILE_REPOSITORY,
      useClass: PrismaCaseFileRepository,
    },
  ],
  exports: [CASE_FILE_REPOSITORY],
})
export class CaseFilesModule {}
