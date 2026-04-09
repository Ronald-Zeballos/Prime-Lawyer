import {
  BadRequestException,
  Controller,
  Get,
  Query,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../../../identity-access/presentation/guards/jwt-auth.guard';
import { GetCaseHistoryUseCase } from '../../application/use-cases/get-case-history/get-case-history.use-case';
import { GetEntityHistoryUseCase } from '../../application/use-cases/get-entity-history/get-entity-history.use-case';
import { SearchAuditLogsRequest } from '../requests/search-audit-logs.request';
import { AuditLogsListResponse } from '../responses/audit-logs-list.response';

@Controller('audit-logs')
@UseGuards(JwtAuthGuard)
export class AuditLogsController {
  constructor(
    private readonly getCaseHistoryUseCase: GetCaseHistoryUseCase,
    private readonly getEntityHistoryUseCase: GetEntityHistoryUseCase,
  ) {}

  @Get()
  async search(
    @Query() request: SearchAuditLogsRequest,
  ): Promise<AuditLogsListResponse> {
    const hasCaseFileFilter = request.caseFileId !== undefined;
    const hasEntityFilter =
      request.entityType !== undefined || request.entityId !== undefined;

    if (hasCaseFileFilter && hasEntityFilter) {
      throw new BadRequestException(
        'Use either caseFileId or entityType/entityId filters, not both.',
      );
    }

    if (request.caseFileId) {
      const auditLogs = await this.getCaseHistoryUseCase.execute({
        caseFileId: request.caseFileId,
      });

      return AuditLogsListResponse.fromDto(auditLogs);
    }

    if (request.entityType && request.entityId) {
      const auditLogs = await this.getEntityHistoryUseCase.execute({
        entityType: request.entityType,
        entityId: request.entityId,
      });

      return AuditLogsListResponse.fromDto(auditLogs);
    }

    throw new BadRequestException(
      'Provide caseFileId or both entityType and entityId.',
    );
  }
}
