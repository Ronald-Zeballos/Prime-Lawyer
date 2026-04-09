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
- `GET /api/v1/case-files/:id`
- `PATCH /api/v1/case-files/:id/status`

Purpose:

- create case file
- list case files
- retrieve case file detail
- change case file status

## Documents

- `POST /api/v1/documents`
- `GET /api/v1/case-files/:caseFileId/documents`
- `GET /api/v1/documents/:id`

Purpose:

- register document metadata and upload file
- list documents by case file
- retrieve document detail

`POST /api/v1/documents` uses multipart form data and stores the file locally for the MVP.

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
- OCR processing is not implemented yet.
- AI and digital signature endpoints are out of scope for this MVP.
