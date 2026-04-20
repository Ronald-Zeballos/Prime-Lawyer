import { ContextualLegalAnswerDto } from '../../application/dto/contextual-legal-answer.dto';

export class ContextualLegalAnswerResponse {
  static fromDto(
    dto: ContextualLegalAnswerDto,
  ): ContextualLegalAnswerDto {
    return dto;
  }
}
