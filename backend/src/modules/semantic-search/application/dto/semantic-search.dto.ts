export type SemanticSearchQueryDto = {
  text: string | null;
  processType: string | null;
  caseFileId: string | null;
  documentId: string | null;
  limit: number;
};

export type SemanticSearchCaseMatchDto = {
  caseFileId: string;
  internalCode: string;
  title: string;
  processType: string;
  status: string;
  visibility: string;
  knowledgeStatus: string;
  score: number;
  matchedDocumentCount: number;
  snippet: string | null;
  matchReasons: string[];
};

export type SemanticSearchDocumentMatchDto = {
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

export type SemanticSearchDto = {
  mode: 'HEURISTIC';
  query: SemanticSearchQueryDto;
  caseMatches: SemanticSearchCaseMatchDto[];
  documentMatches: SemanticSearchDocumentMatchDto[];
};
