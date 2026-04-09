import { CaseFileDto } from '../../application/dto/case-file.dto';
import { CaseFileResponse } from './case-file.response';

export class CaseFilesListResponse {
  items!: CaseFileResponse[];

  static fromDto(dtos: CaseFileDto[]): CaseFilesListResponse {
    return {
      items: dtos.map(CaseFileResponse.fromDto),
    };
  }
}
