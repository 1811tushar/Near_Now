# NearNow Final Audit

## Scope
This package is the complete integrated monorepo assembled as:
- `backend/` — Spring Boot business backend + RAG/AI/agentic integrations
- `ai-service/` — FastAPI P0–P4 AI service
- `consumer_flutter/` — supplied Flutter source scope (`lib/` + `pubspec.yaml`)
- `partner_portal/` — Next.js admin/vendor/warehouse portal
- root `docker-compose.yml` — full local backend + AI + PostgreSQL/pgvector + Redis + portal stack

## Concrete fixes applied in this final audit
1. Standardized agent-facing Spring internal AI endpoints under `/api/internal/ai/**` so the Spring Security allow-list, AI service callers, and controller mapping agree.
2. Fixed two TypeScript syntax errors in the portal Purchase Order UI (`components/ops.tsx`) in the vendor dispatch and warehouse receive mutations.
3. Replaced fabricated P6 portal fraud-review/vendor-review/policy mock interactions with the real Spring Boot endpoints.
4. Changed the Ask Data page from fabricated analytics to an explicit blocked state because the backend currently has no general natural-language data-query endpoint.
5. Changed the Flutter return/refund placeholder so it never claims a request was submitted when no backend submission endpoint exists.
6. Added the missing `razorpay_flutter` dependency required by the existing Flutter payment code.
7. Added root `.env.example` and root `docker-compose.yml` so the complete stack has one documented entry point.
8. Added `partner_portal/public/.gitkeep` so the portal Dockerfile's `COPY public` step has a valid source directory.
9. Removed generated Python bytecode, Node modules/build output and TypeScript build-info artifacts from the distributable package.

## Static verification completed
- Python `compileall` over `ai-service/app`: PASS
- Root and backend Docker Compose YAML parsing: PASS
- TypeScript/TSX parser pass over the portal source: PASS
- Flutter package-import audit against `pubspec.yaml`: PASS
- Java source brace/structure sanity audit: PASS
- Legacy `RestockRequest` active API references: none; the legacy portal page is retained as a non-calling retirement surface as required
- No real `.env` secret file is included

## Runtime verification boundary
The packaging environment does not have Docker or Flutter installed, and Maven dependency resolution cannot reach Maven Central. Therefore this package has **not** been honestly certified here as a complete runtime/build pass. The Windows/Docker verification in `README_INTEGRATED.md` is the final runtime gate.

That limitation is an environment limitation, not a claim that the source is known-broken.

## Final repair pass (2026-09-11)
- Fixed the portal `AdminSeed` missing-export build failure.
- Resolved Spring default bean-name collisions between the three feature-specific `AiServiceClient` classes using explicit bean names.
- Added local-development fallbacks for required root Compose secrets so an absent `.env` does not leave the DB password/JWT/internal key empty.
- Removed the uploaded real `.env` from the distributable package.
- Added root `.gitignore` for local secrets and generated artifacts.
- Corrected `.github/workflows/backend-ci.yml`: CI Postgres now uses `pgvector/pgvector:pg16`, CI supplies required `INTERNAL_API_KEY` and mail placeholders, and GHCR image tags are normalized to lowercase before push.
- Added `RUN_NOW_WINDOWS.md` with the canonical root Compose workflow.

## Final repair after the latest Docker build log

- Fixed the backend Java compiler blocker caused by multiple public automation records living in `AiAutomationDtos.java` by moving each public record to its own correctly named source file.
- Moved `DemandPoint`, `DemandSeries`, and `ThresholdSuggestion` to explicit source files for clean DTO visibility.
- Removed the now-obsolete `AiAutomationDtos.java`.
- Added the missing `Map` import in `ProductService.java`.
- Removed the local secret-bearing root `.env` from the final distributable archive.

The latest supplied Docker log showed the portal was no longer the blocker; the build stopped at the backend compiler with those six errors. These source-level causes are now corrected.
