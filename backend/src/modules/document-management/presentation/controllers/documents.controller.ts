import {
  BadRequestException,
  Body,
  Controller,
  Get,
  Param,
  Post,
  Req,
  Res,
  StreamableFile,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { Request, Response } from 'express';
import { AuthenticatedUserDto } from '../../../identity-access/application/dto/authenticated-user.dto';
import { JwtAuthGuard } from '../../../identity-access/presentation/guards/jwt-auth.guard';
import { ProcessDocumentOcrUseCase } from '../../../ocr-processing/application/use-cases/process-document-ocr/process-document-ocr.use-case';
import { GetDocumentFileUseCase } from '../../application/use-cases/get-document-file/get-document-file.use-case';
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
    private readonly getDocumentFileUseCase: GetDocumentFileUseCase,
    private readonly getDocumentUseCase: GetDocumentUseCase,
    private readonly processDocumentOcrUseCase: ProcessDocumentOcrUseCase,
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

    await this.processDocumentOcrUseCase.execute({
      documentId: document.id,
    });

    const refreshedDocument = await this.getDocumentUseCase.execute({
      id: document.id,
    });

    return DocumentResponse.fromDto(refreshedDocument);
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

  @Post('documents/:id/ocr/process')
  async processOcr(@Param('id') id: string): Promise<DocumentResponse> {
    await this.processDocumentOcrUseCase.execute({ documentId: id });

    const document = await this.getDocumentUseCase.execute({ id });

    return DocumentResponse.fromDto(document);
  }

  @Get('documents/:id/file')
  async getFile(
    @Param('id') id: string,
    @Res({ passthrough: true }) response: Response,
  ): Promise<StreamableFile> {
    const file = await this.getDocumentFileUseCase.execute({ id });

    response.setHeader('Content-Type', file.fileType);
    response.setHeader(
      'Content-Disposition',
      `inline; filename="${encodeURIComponent(file.fileName)}"`,
    );

    return new StreamableFile(file.buffer);
  }
}
