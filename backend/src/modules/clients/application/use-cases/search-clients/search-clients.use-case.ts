import { Inject, Injectable } from '@nestjs/common';
import { UseCase } from '../../../../../shared/application/use-case';
import {
  CLIENT_REPOSITORY,
  ClientRepository,
} from '../../../domain/repositories/client.repository';
import { ClientDto, toClientDto } from '../../dto/client.dto';

export type SearchClientsQuery = {
  term?: string;
};

@Injectable()
export class SearchClientsUseCase
  implements UseCase<SearchClientsQuery, ClientDto[]>
{
  constructor(
    @Inject(CLIENT_REPOSITORY)
    private readonly clientRepository: ClientRepository,
  ) {}

  async execute(query: SearchClientsQuery): Promise<ClientDto[]> {
    const clients = await this.clientRepository.search(query.term);

    return clients.map(toClientDto);
  }
}
