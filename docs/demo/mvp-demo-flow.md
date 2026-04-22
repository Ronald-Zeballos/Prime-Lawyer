# MVP Demo Flow

## Preparation

1. Start PostgreSQL and Redis:

```powershell
cd backend
docker compose up -d postgres redis
```

2. Apply backend migrations and seed the demo data:

```powershell
cd backend
npm run prisma:deploy
npm run seed
```

3. Start the backend:

```powershell
cd backend
npm run start:dev
```

4. Start the mobile app:

```powershell
cd mobile_app
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1
```

## Demo Credentials

- Email: `admin@demo.com`
- Password: `Admin123*`

## Live Demo Script

1. Open the Flutter app and sign in with the demo user.
2. Show the home screen as the landing page after authentication.
3. Open the clients module.
4. Create a new client with basic contact data.
5. Confirm the client appears in the listing.
6. Open the case files module.
7. Create a new case file linked to the client you just created.
8. Confirm the case file appears in the listing.
9. Open the case file detail screen.
10. Enter the documents screen from the case file detail.
11. Register a simple local document with the file picker.
12. Confirm the document appears in the case file document list.
13. Confirm the document now shows OCR status and a local OCR preview.
14. Open the PDF viewer and trigger `Analizar documento`.
15. Confirm the analysis screen shows summary, findings, case matches and document matches.
16. Return to the case detail, close the case and publish it to the collaborative repository.
17. Open the collaborative repository and verify the published case appears there.
18. Explain that the backend registered audit events for login, client creation, case file creation, document registration, OCR processing, status changes and repository publication.

## Optional API Checks

You can verify audit logs directly from the backend:

- `GET /api/v1/audit-logs?caseFileId=<CASE_FILE_ID>`
- `GET /api/v1/audit-logs?entityType=CLIENT&entityId=<CLIENT_ID>`

You can also verify the main resource endpoints:

- `GET /api/v1/clients`
- `GET /api/v1/case-files`
- `GET /api/v1/case-files/<CASE_FILE_ID>/documents`
- `GET /api/v1/semantic-search?documentId=<DOCUMENT_ID>`
- `GET /api/v1/semantic-search?text=contract+breach`
- `POST /api/v1/legal-ai/consultations`

## Notes

- OCR now runs in a local MVP mode. It first tries to recover embedded readable text and falls back to a deterministic simulated OCR result when needed.
- Legal AI now answers only from retrieved user context. If retrieval is weak, it returns insufficient-context guidance instead of inventing a legal answer.
- Digital signature stays out of scope for the MVP.
- File storage is local for the demo, outside the database, and routed through `storage-management` so it can be swapped later for S3/MinIO.
