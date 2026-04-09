import { Inject, Injectable } from '@nestjs/common';
import { NotFoundError } from '../../../../../shared/application/errors/not-found.error';
import { UseCase } from '../../../../../shared/application/use-case';
import {
  CLIENT_REPOSITORY,
  ClientRepository,
} from '../../../domain/repositories/client.repository';
import { ClientId } from '../../../domain/value-objects/client-id.vo';
import { ClientDto, toClientDto } from '../../dto/client.dto';

export type GetClientQuery = {
  id: string;
};

@Injectable()
export class GetClientUseCase implements UseCase<GetClientQuery, ClientDto> {
  constructor(
    @Inject(CLIENT_REPOSITORY)
    private readonly clientRepository: ClientRepository,
  ) {}

  async execute(query: GetClientQuery): Promise<ClientDto> {
    const client = await this.clientRepository.findById(ClientId.create(query.id));

    if (!client) {
      throw new NotFoundError('Client was not found.');
    }

    return toClientDto(client);
  }
}
