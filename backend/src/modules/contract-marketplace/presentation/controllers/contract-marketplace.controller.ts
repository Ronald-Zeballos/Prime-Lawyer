import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  Req,
  Res,
  StreamableFile,
  UseGuards,
} from '@nestjs/common';
import { Request, Response } from 'express';
import { AuthenticatedUserDto } from '../../../identity-access/application/dto/authenticated-user.dto';
import { JwtAuthGuard } from '../../../identity-access/presentation/guards/jwt-auth.guard';
import { GenerateContractFromTemplateUseCase } from '../../application/use-cases/generate-contract-from-template/generate-contract-from-template.use-case';
import { GetContractTemplateUseCase } from '../../application/use-cases/get-contract-template/get-contract-template.use-case';
import { GetContractInstancePdfUseCase } from '../../application/use-cases/get-contract-instance-pdf/get-contract-instance-pdf.use-case';
import { ListActiveContractTemplatesUseCase } from '../../application/use-cases/list-active-contract-templates/list-active-contract-templates.use-case';
import { ListUserContractInstancesUseCase } from '../../application/use-cases/list-user-contract-instances/list-user-contract-instances.use-case';
import { GenerateContractRequest } from '../requests/generate-contract.request';
import { ContractInstanceResponse } from '../responses/contract-instance.response';
import { ContractInstancesListResponse } from '../responses/contract-instances-list.response';
import { ContractTemplateResponse } from '../responses/contract-template.response';
import { ContractTemplatesListResponse } from '../responses/contract-templates-list.response';

@Controller('contract-marketplace')
@UseGuards(JwtAuthGuard)
export class ContractMarketplaceController {
  constructor(
    private readonly listActiveContractTemplatesUseCase: ListActiveContractTemplatesUseCase,
    private readonly getContractTemplateUseCase: GetContractTemplateUseCase,
    private readonly generateContractFromTemplateUseCase: GenerateContractFromTemplateUseCase,
    private readonly listUserContractInstancesUseCase: ListUserContractInstancesUseCase,
    private readonly getContractInstancePdfUseCase: GetContractInstancePdfUseCase,
  ) {}

  @Get('templates')
  async listTemplates(): Promise<ContractTemplatesListResponse> {
    const templates = await this.listActiveContractTemplatesUseCase.execute();

    return ContractTemplatesListResponse.fromDto(templates);
  }

  @Get('templates/:slug')
  async getTemplate(
    @Param('slug') slug: string,
  ): Promise<ContractTemplateResponse> {
    const template = await this.getContractTemplateUseCase.execute({ slug });

    return ContractTemplateResponse.fromDto(template);
  }

  @Post('templates/:slug/generate')
  async generateFromTemplate(
    @Param('slug') slug: string,
    @Body() request: GenerateContractRequest,
    @Req()
    httpRequest: Request & {
      user: AuthenticatedUserDto;
    },
  ): Promise<ContractInstanceResponse> {
    const contractInstance =
      await this.generateContractFromTemplateUseCase.execute({
        templateSlug: slug,
        requesterId: httpRequest.user.id,
        values: request.values,
      });

    return ContractInstanceResponse.fromDto(contractInstance);
  }

  @Get('instances')
  async listUserInstances(
    @Req()
    httpRequest: Request & {
      user: AuthenticatedUserDto;
    },
  ): Promise<ContractInstancesListResponse> {
    const instances = await this.listUserContractInstancesUseCase.execute({
      requesterId: httpRequest.user.id,
    });

    return ContractInstancesListResponse.fromDto(instances);
  }

  @Get('instances/:id/file')
  async getInstanceFile(
    @Param('id') id: string,
    @Req()
    httpRequest: Request & {
      user: AuthenticatedUserDto;
    },
    @Res({ passthrough: true }) response: Response,
  ): Promise<StreamableFile> {
    const file = await this.getContractInstancePdfUseCase.execute({
      id,
      requesterId: httpRequest.user.id,
    });

    response.setHeader('Content-Type', file.fileType);
    response.setHeader(
      'Content-Disposition',
      `inline; filename="${encodeURIComponent(file.fileName)}"`,
    );

    return new StreamableFile(file.buffer);
  }
}
