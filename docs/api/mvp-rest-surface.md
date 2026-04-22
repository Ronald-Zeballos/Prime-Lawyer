# MVP REST Surface

Current implemented REST API for the MVP.

Global prefix:

- `/api/v1`

## Auth

- `POST /api/v1/auth/login`
- `GET /api/v1/auth/me`

Purpose:

- authenticate with email and password
- return JWT access token
- retrieve the authenticated user

## Clients

- `POST /api/v1/clients`
- `PATCH /api/v1/clients/:id`
- `GET /api/v1/clients`
- `GET /api/v1/clients/:id`

Purpose:

- create client
- update client
- list clients
- get client detail

## Case Files

- `POST /api/v1/case-files`
- `GET /api/v1/case-files`
- `GET /api/v1/case-files/repository`
- `GET /api/v1/case-files/:id`
- `PATCH /api/v1/case-files/:id/status`
- `PATCH /api/v1/case-files/:id/publication`

Purpose:

- create case file
- list case files
- list the collaborative repository of published closed cases
- retrieve case file detail
- change case file status
- publish or remove a closed case from the shared repository

## Documents

- `POST /api/v1/documents`
- `GET /api/v1/case-files/:caseFileId/documents`
- `GET /api/v1/documents/:id`
- `POST /api/v1/documents/:id/ocr/process`

Purpose:

- register document metadata, upload file and trigger local OCR MVP processing
- list documents by case file
- retrieve document detail
- retry OCR processing for a document

`POST /api/v1/documents` uses multipart form data, stores the file locally outside the database and returns OCR status plus OCR text fields.

## Semantic Search

- `GET /api/v1/semantic-search?text=:text`
- `GET /api/v1/semantic-search?processType=:processType`
- `GET /api/v1/semantic-search?documentId=:documentId`
- `GET /api/v1/semantic-search?caseFileId=:caseFileId`

Purpose:

- recover similar case files using text, process type and OCR-backed document signals
- recover similar documents using file names, OCR text and parent case metadata
- provide the first heuristic retrieval layer before embeddings exist

The response returns separate `caseMatches` and `documentMatches` arrays, each with scores and match reasons.

## Legal AI

- `POST /api/v1/legal-ai/consultations`
- `GET /api/v1/legal-ai/documents/:documentId/analysis-preview`

Purpose:

- answer legal questions using only retrieved cases and documents from the current user
- persist the consultation plus the cases used as grounding context
- expose a contextual legal answer before embeddings or a full LLM provider are introduced
- keep document analysis preview for the PDF viewer flow

`POST /api/v1/legal-ai/consultations` accepts JSON:

```json
{
  "question": "Que contexto recuperado habla de incumplimiento de contrato de alquiler?",
  "caseFileId": "optional-case-id",
  "documentId": "optional-document-id",
  "processType": "optional-process-type",
  "limit": 3
}
```

The response includes:

- grounded answer text
- `groundingStatus` to show whether the answer is grounded, partial, or blocked by insufficient context
- `usedContextCases` and `usedContextDocuments`
- full retrieval payload used to build the answer
- persisted `queryId`

`GET /api/v1/legal-ai/documents/:documentId/analysis-preview` now returns:

- source case and source document metadata
- case matches with score, matched document count, snippet, visibility and knowledge status
- document matches with score, snippet and match reasons
- highlights, limitations and recommended next steps for the PDF viewer experience

## Audit Logs

- `GET /api/v1/audit-logs?caseFileId=:caseFileId`
- `GET /api/v1/audit-logs?entityType=:entityType&entityId=:entityId`

Purpose:

- list audit events by case file
- list audit events by entity

Current audit registration points:

- successful login
- client creation
- client update
- case file creation
- case file status change
- document registration

## Authentication

Private endpoints require `Authorization: Bearer <token>`.

## Current MVP Limits

- Swagger is not enabled yet.
- OCR processing is implemented as a local MVP heuristic. It recovers embedded readable text when possible and otherwise generates a consistent simulated OCR result.
- Semantic search is heuristic for now. It uses metadata, OCR text and basic scoring rules, not vector embeddings yet.
- Legal AI is grounded in retrieved cases/documents, but it is still heuristic and does not use embeddings or an external LLM provider yet.
