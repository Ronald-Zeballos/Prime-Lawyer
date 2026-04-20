import {
  ContextualLegalAnswerDraftDto,
  ContextualLegalContextCaseDto,
  ContextualLegalContextDocumentDto,
  ContextualLegalSourceCaseFileDto,
  ContextualLegalSourceDocumentDto,
} from '../dto/contextual-legal-answer.dto';
import { SemanticSearchDto } from '../../../semantic-search/application/dto/semantic-search.dto';

export const CONTEXTUAL_LEGAL_ANSWER_BUILDER = Symbol(
  'CONTEXTUAL_LEGAL_ANSWER_BUILDER',
);

export type BuildContextualLegalAnswerCommand = {
  question: string;
  sourceCaseFile: ContextualLegalSourceCaseFileDto | null;
  sourceDocument: ContextualLegalSourceDocumentDto | null;
  usedContextCases: ContextualLegalContextCaseDto[];
  usedContextDocuments: ContextualLegalContextDocumentDto[];
  retrieval: SemanticSearchDto;
};

export interface ContextualLegalAnswerBuilder {
  build(
    command: BuildContextualLegalAnswerCommand,
  ): ContextualLegalAnswerDraftDto;
}
