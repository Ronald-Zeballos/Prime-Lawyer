import { SemanticSearchDto } from '../../../semantic-search/application/dto/semantic-search.dto';

export type ContextualLegalAnswerMode = 'CONTEXTUAL_HEURISTIC';

export type ContextualLegalGroundingStatus =
  | 'GROUNDED'
  | 'PARTIAL'
  | 'INSUFFICIENT_CONTEXT';

export type ContextualLegalAnswerLanguage = 'es' | 'en';

export type ContextualLegalSourceCaseFileDto = {
  id: string;
  internalCode: string;
  title: string;
  descriptionSnippet: string | null;
  processType: string;
  status: string;
  visibility: string;
  knowledgeStatus: string;
};

export type ContextualLegalSourceDocumentDto = {
  id: string;
  caseFileId: string;
  originalName: string;
  fileType: string;
  ocrStatus: string;
  uploadSource: string;
  snippet: string | null;
};

export type ContextualLegalContextCaseDto = {
  rank: number;
  relation: 'SOURCE_CASE' | 'SIMILAR_CASE';
  caseFileId: string;
  internalCode: string;
  title: string;
  processType: string;
  status: string;
  visibility: string;
  knowledgeStatus: string;
  score: number;
  snippet: string | null;
  matchReasons: string[];
};

export type ContextualLegalContextDocumentDto = {
  rank: number;
  relation: 'SOURCE_DOCUMENT' | 'SIMILAR_DOCUMENT';
  documentId: string;
  caseFileId: string;
  caseInternalCode: string;
  caseTitle: string;
  processType: string;
  status: string;
  originalName: string;
  fileType: string;
  ocrStatus: string;
  score: number;
  snippet: string | null;
  matchReasons: string[];
};

export type ContextualLegalAnswerDraftDto = {
  language: ContextualLegalAnswerLanguage;
  groundingStatus: ContextualLegalGroundingStatus;
  answer: string;
  disclaimer: string;
  limitations: string[];
  recommendedNextSteps: string[];
  followUpQuestions: string[];
};

export type ContextualLegalAnswerDto = ContextualLegalAnswerDraftDto & {
  queryId: string;
  mode: ContextualLegalAnswerMode;
  question: string;
  sourceCaseFile: ContextualLegalSourceCaseFileDto | null;
  sourceDocument: ContextualLegalSourceDocumentDto | null;
  usedContextCases: ContextualLegalContextCaseDto[];
  usedContextDocuments: ContextualLegalContextDocumentDto[];
  retrieval: SemanticSearchDto;
  createdAt: Date;
};
