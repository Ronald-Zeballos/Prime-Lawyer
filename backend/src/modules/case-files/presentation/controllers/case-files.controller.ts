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
import { SearchCaseFilesUseCase } from '../../application/use-cases/search-case-files/search-case-files.use-case';
import { ChangeCaseStatusRequest } from '../requests/change-case-status.request';
import { CreateCaseFileRequest } from '../requests/create-case-file.request';
import { SearchCaseFilesRequest } from '../requests/search-case-files.request';
import { CaseFileResponse } from '../responses/case-file.response';
import { CaseFilesListResponse } from '../responses/case-files-list.response';

@Controller('case-files')
@UseGuards(JwtAuthGuard)
export class CaseFilesController {
  constructor(
    private readonly createCaseFileUseCase: CreateCaseFileUseCase,
    private readonly getCaseFileUseCase: GetCaseFileUseCase,
    private readonly searchCaseFilesUseCase: SearchCaseFilesUseCase,
    private readonly changeCaseStatusUseCase: ChangeCaseStatusUseCase,
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
      clientId: request.clientId,
      subject: request.subject,
      processType: request.processType,
      responsibleUserId: request.responsibleUserId,
      confidentialityLevel: request.confidentialityLevel,
      performedById: httpRequest.user.id,
    });

    return CaseFileResponse.fromDto(caseFile);
  }

  @Get()
  async search(
    @Query() request: SearchCaseFilesRequest,
  ): Promise<CaseFilesListResponse> {
    const caseFiles = await this.searchCaseFilesUseCase.execute({
      term: request.term,
      clientId: request.clientId,
      status: request.status,
    });

    return CaseFilesListResponse.fromDto(caseFiles);
  }

  @Get(':id')
  async getById(@Param('id') id: string): Promise<CaseFileResponse> {
    const caseFile = await this.getCaseFileUseCase.execute({ id });

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
