import { DocumentDto } from '../../application/dto/document.dto';
import { DocumentResponse } from './document.response';

export class DocumentsListResponse {
  items!: DocumentResponse[];

  static fromDto(dtos: DocumentDto[]): DocumentsListResponse {
    return {
      items: dtos.map(DocumentResponse.fromDto),
    };
  }
}
