import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import { Request } from 'express';
import { AuthenticatedUserDto } from '../../../identity-access/application/dto/authenticated-user.dto';
import { JwtAuthGuard } from '../../../identity-access/presentation/guards/jwt-auth.guard';
import { CreateClientUseCase } from '../../application/use-cases/create-client/create-client.use-case';
import { GetClientUseCase } from '../../application/use-cases/get-client/get-client.use-case';
import { SearchClientsUseCase } from '../../application/use-cases/search-clients/search-clients.use-case';
import { UpdateClientUseCase } from '../../application/use-cases/update-client/update-client.use-case';
import { CreateClientRequest } from '../requests/create-client.request';
import { SearchClientsRequest } from '../requests/search-clients.request';
import { UpdateClientRequest } from '../requests/update-client.request';
import { ClientResponse } from '../responses/client.response';
import { ClientsListResponse } from '../responses/clients-list.response';

@Controller('clients')
@UseGuards(JwtAuthGuard)
export class ClientsController {
  constructor(
    private readonly createClientUseCase: CreateClientUseCase,
    private readonly updateClientUseCase: UpdateClientUseCase,
    private readonly getClientUseCase: GetClientUseCase,
    private readonly searchClientsUseCase: SearchClientsUseCase,
  ) {}

  @Post()
  async create(
    @Body() request: CreateClientRequest,
    @Req()
    httpRequest: Request & {
      user: AuthenticatedUserDto;
    },
  ): Promise<ClientResponse> {
    const client = await this.createClientUseCase.execute({
      firstName: request.firstName,
      lastName: request.lastName,
      documentNumber: request.documentNumber,
      phone: request.phone,
      email: request.email,
      address: request.address,
      notes: request.notes,
      performedById: httpRequest.user.id,
    });

    return ClientResponse.fromDto(client);
  }

  @Patch(':id')
  async update(
    @Param('id') id: string,
    @Body() request: UpdateClientRequest,
    @Req()
    httpRequest: Request & {
      user: AuthenticatedUserDto;
    },
  ): Promise<ClientResponse> {
    const client = await this.updateClientUseCase.execute({
      id,
      firstName: request.firstName,
      lastName: request.lastName,
      documentNumber: request.documentNumber,
      phone: request.phone,
      email: request.email,
      address: request.address,
      notes: request.notes,
      performedById: httpRequest.user.id,
    });

    return ClientResponse.fromDto(client);
  }

  @Get()
  async search(@Query() request: SearchClientsRequest): Promise<ClientsListResponse> {
    const clients = await this.searchClientsUseCase.execute({
      term: request.term,
    });

    return ClientsListResponse.fromDto(clients);
  }

  @Get(':id')
  async getById(@Param('id') id: string): Promise<ClientResponse> {
    const client = await this.getClientUseCase.execute({ id });

    return ClientResponse.fromDto(client);
  }
}
