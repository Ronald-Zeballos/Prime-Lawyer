import { ClientDto } from '../../application/dto/client.dto';
import { ClientResponse } from './client.response';

export class ClientsListResponse {
  items!: ClientResponse[];

  static fromDto(dtos: ClientDto[]): ClientsListResponse {
    return {
      items: dtos.map(ClientResponse.fromDto),
    };
  }
}
