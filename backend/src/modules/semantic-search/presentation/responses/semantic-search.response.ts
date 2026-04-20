import { SemanticSearchDto } from '../../application/dto/semantic-search.dto';

export class SemanticSearchResponse {
  static fromDto(dto: SemanticSearchDto): SemanticSearchDto {
    return dto;
  }
}
