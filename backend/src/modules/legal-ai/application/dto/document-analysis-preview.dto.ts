export type DocumentAnalysisPreviewSourceCaseFileDto = {
  id: string;
  internalCode: string;
  title: string;
  processType: string;
  status: string;
  confidentialityLevel: string;
};

export type DocumentAnalysisPreviewSourceDocumentDto = {
  id: string;
  originalName: string;
  fileType: string;
  ocrStatus: string;
  uploadSource: string;
};

export type DocumentAnalysisPreviewMatchDto = {
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

export type DocumentAnalysisPreviewDocumentMatchDto = {
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

export type DocumentAnalysisPreviewDto = {
  mode: 'PREVIEW';
  summary: string;
  sourceCaseFile: DocumentAnalysisPreviewSourceCaseFileDto;
  sourceDocument: DocumentAnalysisPreviewSourceDocumentDto;
  highlights: string[];
  limitations: string[];
  recommendedNextSteps: string[];
  matches: DocumentAnalysisPreviewMatchDto[];
  documentMatches: DocumentAnalysisPreviewDocumentMatchDto[];
};
