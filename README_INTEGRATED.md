# NearNow — Integrated Applied AI Package

This is the final P0–P6 integration package for NearNow. It is intended to be merged/replaced into the existing monorepo, not run by double-clicking individual files.

## Included
- `backend/` — Spring Boot backend plus AI/RAG/automation/agentic/hardening integrations
- `ai-service/` — FastAPI AI microservice
- `consumer_flutter/` — Flutter `lib/` plus `pubspec.yaml` updates required by P6
- `partner_portal/` — Next.js portal with AI surfaces and PurchaseOrder UI
- `.github/workflows/backend-ci.yml` — backend + portal CI

## Before running
1. Copy/create the real environment variables from the supplied `.env.example` files.
2. Set the same `INTERNAL_API_KEY` for Spring Boot and `ai-service`.
3. Set `GEMINI_API_KEY` if you want Gemini-backed P1/P3/P4 features.
4. Keep `PAYMENT_MODE=MOCK` for local zero-cost testing unless you intentionally configure Razorpay test credentials.

## Windows verification
From the monorepo root, after Docker Desktop is running:

```powershell
docker compose --profile monitoring up -d --build
```

Then verify the AI service and backend, and run the backend tests:

```powershell
curl http://localhost:8001/health
.\mvnw.cmd test "-Dtest=!OrderPlacementIntegrationTest"
```

For the portal:

```powershell
cd ..\partner_portal
npm ci
npm run typecheck
npm run build
```

For Flutter, run the normal project-level `flutter pub get` and `flutter analyze` from your existing full Flutter project after replacing its `lib/` and applying the included `pubspec.yaml` dependency changes.

`OrderPlacementIntegrationTest` is intentionally excluded from the local Windows Maven command because the project documentation records the known Testcontainers/npipe Windows limitation; GitHub Actions Linux is the source of truth for that test.

## Important
The legacy `partner_portal/app/vendor/products/[id]/restock-request/page.tsx` is intentionally **not deleted**. It is a non-calling retirement/deprecation page. Active replenishment uses Purchase Orders.

See `INTEGRATION_REPORT.md` for the exact integration status and known verification limitations.
