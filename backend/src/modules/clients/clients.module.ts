import { Module } from '@nestjs/common';
import { IdentityAccessModule } from '../identity-access/identity-access.module';
import { ClientsController } from './presentation/controllers/clients.controller';
import { CreateClientUseCase } from './application/use-cases/create-client/create-client.use-case';
import { UpdateClientUseCase } from './application/use-cases/update-client/update-client.use-case';
import { GetClientUseCase } from './application/use-cases/get-client/get-client.use-case';
import { SearchClientsUseCase } from './application/use-cases/search-clients/search-clients.use-case';
import { CLIENT_REPOSITORY } from './domain/repositories/client.repository';
import { PrismaClientRepository } from './infrastructure/persistence/repositories/prisma-client.repository';

@Module({
  imports: [IdentityAccessModule],
  controllers: [ClientsController],
  providers: [
    CreateClientUseCase,
    UpdateClientUseCase,
    GetClientUseCase,
    SearchClientsUseCase,
    {
      provide: CLIENT_REPOSITORY,
      useClass: PrismaClientRepository,
    },
  ],
  exports: [CLIENT_REPOSITORY],
})
export class ClientsModule {}
