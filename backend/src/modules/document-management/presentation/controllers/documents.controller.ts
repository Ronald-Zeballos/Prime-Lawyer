import {
  BadRequestException,
  Body,
  Controller,
  Get,
  Param,
  Post,
  Req,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { Request } from 'express';
import { AuthenticatedUserDto } from '../../../identity-access/application/dto/authenticated-user.dto';
import { JwtAuthGuard } from '../../../identity-access/presentation/guards/jwt-auth.guard';
import { GetDocumentUseCase } from '../../application/use-cases/get-document/get-document.use-case';
import { ListCaseDocumentsUseCase } from '../../application/use-cases/list-case-documents/list-case-documents.use-case';
import { RegisterDocumentUseCase } from '../../application/use-cases/register-document/register-document.use-case';
import { RegisterDocumentRequest } from '../requests/register-document.request';
import { DocumentResponse } from '../responses/document.response';
import { DocumentsListResponse } from '../responses/documents-list.response';

type UploadedDocumentFile = {
  originalname: string;
  mimetype: string;
  buffer: Buffer;
  size: number;
};

@Controller()
@UseGuards(JwtAuthGuard)
export class DocumentsController {
  constructor(
    private readonly registerDocumentUseCase: RegisterDocumentUseCase,
    private readonly listCaseDocumentsUseCase: ListCaseDocumentsUseCase,
    private readonly getDocumentUseCase: GetDocumentUseCase,
  ) {}

  @Post('documents')
  @UseInterceptors(
    FileInterceptor('file', {
      limits: {
        fileSize: 15 * 1024 * 1024,
      },
    }),
  )
  async register(
    @UploadedFile() file: UploadedDocumentFile | undefined,
    @Body() request: RegisterDocumentRequest,
    @Req()
    httpRequest: Request & {
      user: AuthenticatedUserDto;
    },
  ): Promise<DocumentResponse> {
    if (!file) {
      throw new BadRequestException('A file is required.');
    }

    const document = await this.registerDocumentUseCase.execute({
      caseFileId: request.caseFileId,
      originalName: file.originalname,
      fileType: file.mimetype,
      uploadSource: request.uploadSource ?? 'mobile_app',
      uploadedById: httpRequest.user.id,
      fileBuffer: file.buffer,
    });

    return DocumentResponse.fromDto(document);
  }

  @Get('case-files/:caseFileId/documents')
  async listByCaseFile(
    @Param('caseFileId') caseFileId: string,
  ): Promise<DocumentsListResponse> {
    const documents = await this.listCaseDocumentsUseCase.execute({ caseFileId });

    return DocumentsListResponse.fromDto(documents);
  }

  @Get('documents/:id')
  async getById(@Param('id') id: string): Promise<DocumentResponse> {
    const document = await this.getDocumentUseCase.execute({ id });

    return DocumentResponse.fromDto(document);
  }
}
