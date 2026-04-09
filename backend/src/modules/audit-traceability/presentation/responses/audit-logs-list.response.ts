import { AuditLogDto } from '../../application/dto/audit-log.dto';
import { AuditLogResponse } from './audit-log.response';

export class AuditLogsListResponse {
  items!: AuditLogResponse[];

  static fromDto(dtos: AuditLogDto[]): AuditLogsListResponse {
    return {
      items: dtos.map(AuditLogResponse.fromDto),
    };
  }
}
