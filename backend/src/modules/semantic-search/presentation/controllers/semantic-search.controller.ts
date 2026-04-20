import { Controller, Get, Query, Req, UseGuards } from '@nestjs/common';
import { Request } from 'express';
import { AuthenticatedUserDto } from '../../../identity-access/application/dto/authenticated-user.dto';
import { JwtAuthGuard } from '../../../identity-access/presentation/guards/jwt-auth.guard';
import { SearchSemanticContentUseCase } from '../../application/use-cases/search-semantic-content/search-semantic-content.use-case';
import { SearchSemanticRequest } from '../requests/search-semantic.request';
import { SemanticSearchResponse } from '../responses/semantic-search.response';

@Controller('semantic-search')
@UseGuards(JwtAuthGuard)
export class SemanticSearchController {
  constructor(
    private readonly searchSemanticContentUseCase: SearchSemanticContentUseCase,
  ) {}

  @Get()
  async search(
    @Query() request: SearchSemanticRequest,
    @Req()
    httpRequest: Request & {
      user: AuthenticatedUserDto;
    },
  ): Promise<SemanticSearchResponse> {
    const result = await this.searchSemanticContentUseCase.execute({
      requesterId: httpRequest.user.id,
      text: request.text,
      processType: request.processType,
      caseFileId: request.caseFileId,
      documentId: request.documentId,
      limit: request.limit,
    });

    return SemanticSearchResponse.fromDto(result);
  }
}
