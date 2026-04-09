# Monorepo MVP Architecture

## Purpose

This monorepo keeps the backend API and the Flutter mobile app together to simplify coordinated delivery, demo setup and API contract evolution.

## Execution Model

- `backend/` is the only NestJS executable for server-side logic.
- `mobile_app/` is the only Flutter executable for the client application.
- They share a repository, not a runtime.

## Backend Direction

- Monolith
- Modular by domain
- DDD-oriented
- Hexagonal boundaries
- REST API for mobile consumption

## Mobile Direction

- Single Flutter app
- Modular by feature
- Separation between `data`, `domain` and `presentation`
- Local token storage and authenticated API consumption

## MVP Modules

Backend:

- `identity-access`
- `clients`
- `case-files`
- `document-management`
- `audit-traceability`

Mobile:

- `auth`
- `profile`
- `home`
- `clients`
- `case_files`
- `document_capture`
- `documents`
