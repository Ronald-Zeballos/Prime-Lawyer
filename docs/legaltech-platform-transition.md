# Prime Lawyer - LegalTech platform transition

## Product reset

The project is moving from an internal law-firm workflow to an open LegalTech platform.

New product pillars:
- legal AI with contextual retrieval
- collaborative case repository
- contract marketplace
- monetization through plans, tokens, contracts, and future ads

## Transitional architecture decision

The current codebase is being migrated in controlled steps.

For this first transition block:
- the existing backend modules remain available so the repository keeps compiling
- the new product schema has been introduced into Prisma without deleting the legacy tables yet
- new backend modules required by the new business model are already scaffolded

This keeps the monolith stable while we replace legacy workflows incrementally.

## What is already reusable

Reusable with minor adaptation:
- `identity-access`
- `document-management`
- `storage-management`
- `audit-traceability`
- `shared`
- Flutter network/session base

Reusable but domain-shifted:
- `case-files` -> user-owned legal cases
- `legal-ai` -> contextual legal AI over real cases
- `ocr-processing` -> OCR pipeline for uploaded files
- `contracts` -> contract marketplace
- `search-indexing` -> semantic search

Legacy and no longer central:
- `clients`
- `courses`
- `digital-signature`
- `notifications`
- `jurisprudence`

## New schema capabilities introduced

The Prisma schema now includes the product foundations for:
- `UserType`
- `PlanType`
- `CaseVisibility`
- `KnowledgeStatus`
- `DocumentSource`
- `PaymentType`
- `PaymentStatus`
- `SubscriptionStatus`
- `AIQueryStatus`

And the new platform models:
- `AIQuery`
- `AIQueryContextCase`
- `SemanticChunk`
- `ContractTemplate`
- `ContractInstance`
- `Payment`
- `Subscription`

The current `User`, `CaseFile`, and `Document` models were extended instead of replaced so the repo can migrate safely.

## New backend modules scaffolded

- `semantic-search`
- `contract-marketplace`
- `payments`
- `subscription`
- `ocr-processing` module entrypoint
- `storage-management` module entrypoint
- `user-profile` module entrypoint

## Seed data now available

- `admin@demo.com`
- `lawyer@demo.com`
- one demo contract template: `lease-agreement-basic`

## Recommended next implementation block

1. Refactor `identity-access` to support `NATURAL | LAWYER | ADMIN`
2. Refactor `case-files` from internal expediente to open user-owned legal case
3. Refactor `document-management` to align with OCR text and semantic preparation
4. Introduce `semantic-search` MVP using text-based retrieval first
5. Upgrade `legal-ai` to answer only with retrieved context
6. Implement `contract-marketplace` MVP with one purchasable template

## Validation completed

Validated after this transition block:
- Prisma schema validation
- Prisma client generation
- NestJS build
