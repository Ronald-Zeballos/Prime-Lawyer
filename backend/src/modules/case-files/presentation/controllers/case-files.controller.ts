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
import { ChangeCaseStatusUseCase } from '../../application/use-cases/change-case-status/change-case-status.use-case';
import { CreateCaseFileUseCase } from '../../application/use-cases/create-case-file/create-case-file.use-case';
import { GetCaseFileUseCase } from '../../application/use-cases/get-case-file/get-case-file.use-case';
import { SearchCollaborativeCaseRepositoryUseCase } from '../../application/use-cases/search-collaborative-case-repository/search-collaborative-case-repository.use-case';
import { SearchCaseFilesUseCase } from '../../application/use-cases/search-case-files/search-case-files.use-case';
import { UpdateCaseKnowledgePublicationUseCase } from '../../application/use-cases/update-case-knowledge-publication/update-case-knowledge-publication.use-case';
import { ChangeCaseStatusRequest } from '../requests/change-case-status.request';
import { CreateCaseFileRequest } from '../requests/create-case-file.request';
import { SearchCollaborativeCaseRepositoryRequest } from '../requests/search-collaborative-case-repository.request';
import { SearchCaseFilesRequest } from '../requests/search-case-files.request';
import { UpdateCaseKnowledgePublicationRequest } from '../requests/update-case-knowledge-publication.request';
import { CaseFileResponse } from '../responses/case-file.response';
import { CaseFilesListResponse } from '../responses/case-files-list.response';

@Controller('case-files')
@UseGuards(JwtAuthGuard)
export class CaseFilesController {
  constructor(
    private readonly createCaseFileUseCase: CreateCaseFileUseCase,
    private readonly getCaseFileUseCase: GetCaseFileUseCase,
    private readonly searchCaseFilesUseCase: SearchCaseFilesUseCase,
    private readonly searchCollaborativeCaseRepositoryUseCase: SearchCollaborativeCaseRepositoryUseCase,
    private readonly changeCaseStatusUseCase: ChangeCaseStatusUseCase,
    private readonly updateCaseKnowledgePublicationUseCase: UpdateCaseKnowledgePublicationUseCase,
  ) {}

  @Post()
  async create(
    @Body() request: CreateCaseFileRequest,
    @Req()
    httpRequest: Request & {
      user: AuthenticatedUserDto;
    },
  ): Promise<CaseFileResponse> {
    const caseFile = await this.createCaseFileUseCase.execute({
      internalCode: request.internalCode,
      title: request.title,
      description: request.description,
      processType: request.processType,
      confidentialityLevel: request.confidentialityLevel,
      performedById: httpRequest.user.id,
    });

    return CaseFileResponse.fromDto(caseFile);
  }

  @Get()
  async search(
    @Query() request: SearchCaseFilesRequest,
    @Req()
    httpRequest: Request & {
      user: AuthenticatedUserDto;
    },
  ): Promise<CaseFilesListResponse> {
    const caseFiles = await this.searchCaseFilesUseCase.execute({
      term: request.term,
      status: request.status,
      ownerUserId: httpRequest.user.id,
    });

    return CaseFilesListResponse.fromDto(caseFiles);
  }

  @Get('repository')
  async searchCollaborativeRepository(
    @Query() request: SearchCollaborativeCaseRepositoryRequest,
  ): Promise<CaseFilesListResponse> {
    const caseFiles =
      await this.searchCollaborativeCaseRepositoryUseCase.execute({
        term: request.term,
        processType: request.processType,
      });

    return CaseFilesListResponse.fromDto(caseFiles);
  }

  @Get(':id')
  async getById(
    @Param('id') id: string,
    @Req()
    httpRequest: Request & {
      user: AuthenticatedUserDto;
    },
  ): Promise<CaseFileResponse> {
    const caseFile = await this.getCaseFileUseCase.execute({
      id,
      requesterId: httpRequest.user.id,
    });

    return CaseFileResponse.fromDto(caseFile);
  }

  @Patch(':id/publication')
  async updatePublication(
    @Param('id') id: string,
    @Body() request: UpdateCaseKnowledgePublicationRequest,
    @Req()
    httpRequest: Request & {
      user: AuthenticatedUserDto;
    },
  ): Promise<CaseFileResponse> {
    const caseFile = await this.updateCaseKnowledgePublicationUseCase.execute({
      id,
      publish: request.publish,
      performedById: httpRequest.user.id,
    });

    return CaseFileResponse.fromDto(caseFile);
  }

  @Patch(':id/status')
  async changeStatus(
    @Param('id') id: string,
    @Body() request: ChangeCaseStatusRequest,
    @Req()
    httpRequest: Request & {
      user: AuthenticatedUserDto;
    },
  ): Promise<CaseFileResponse> {
    const caseFile = await this.changeCaseStatusUseCase.execute({
      id,
      status: request.status,
      performedById: httpRequest.user.id,
    });

    return CaseFileResponse.fromDto(caseFile);
  }
}
