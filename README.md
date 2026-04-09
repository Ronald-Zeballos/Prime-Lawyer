# Prime Lawyer Monorepo

Monorepo for the Prime Lawyer MVP. The repository contains one NestJS backend and one Flutter mobile app, developed side by side but executed independently.

## Repository Layout

- `backend/`: NestJS modular monolith for authentication, clients, case files, documents and audit trail.
- `mobile_app/`: Flutter mobile app that consumes the backend REST API.
- `docs/`: architecture notes, API notes and demo guidance.
- `infra/`: local infrastructure notes for PostgreSQL, Redis and future MinIO support.
- `scripts/`: operational notes and future helper scripts.

## MVP Scope

Backend MVP modules:

- `identity-access`
- `clients`
- `case-files`
- `document-management`
- `audit-traceability`

Mobile MVP modules:

- `auth`
- `profile`
- `home`
- `clients`
- `case_files`
- `document_capture`
- `documents`

## Current Status

- Backend MVP flow implemented
- Mobile MVP flow implemented at code level
- Local document storage implemented under `backend/uploads/`
- Audit logging integrated into the main backend use cases
- Backend build verified
- Prisma schema validation verified

Current end-to-end demo flow:

1. Sign in with the demo administrator.
2. Create a client.
3. Create a case file for that client.
4. Register a document for the case file.
5. Review case file and document listings.
6. Explain the audit trail through the API.

## Prerequisites

- Node.js 20+ installed
- Flutter SDK installed
- Docker Desktop running locally
- VS Code opened at the repository root

If `npm` is not recognized on Windows, add `C:\Program Files\nodejs` to your `PATH`.

## Backend Local Run

1. Copy `backend/.env.example` to `backend/.env`.
2. Update `DATABASE_URL` if needed. For local Docker, this value works:

```env
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/prime_lawyer?schema=public
```

3. Start local infrastructure:

```powershell
cd backend
docker compose up -d postgres redis
```

4. Install backend dependencies:

```powershell
cd backend
npm install
```

5. Apply migrations and seed demo data:

```powershell
cd backend
npm run prisma:deploy
npm run seed
```

6. Start the API:

```powershell
cd backend
npm run start:dev
```

The backend will run on `http://localhost:3000` with global API prefix `http://localhost:3000/api/v1`.

Demo user:

- Email: `admin@demo.com`
- Password: `Admin123*`

## Mobile Local Run

The mobile app expects the backend API to be available first.

```powershell
cd mobile_app
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1
```

Notes:

- `10.0.2.2` is the Android emulator alias for the host machine.
- For iOS simulator or desktop, use `http://localhost:3000/api/v1`.
- For a physical device, use your machine LAN IP.

## Demo Notes

- OCR is not implemented yet. `ocrStatus` is stored for future growth.
- Legal AI is out of scope for this MVP.
- Digital signature is out of scope for this MVP.
- Storage is local for the MVP and intentionally simple to explain.

## Key Docs

- `docs/architecture/monorepo-mvp.md`
- `docs/api/mvp-rest-surface.md`
- `docs/demo/mvp-demo-flow.md`
