# NearNow Final Integrated Package

This is the complete integrated monorepo package assembled from the supplied NearNow baseline and P0–P6 workstreams.

## Included
- `backend/` — complete supplied Spring Boot backend with RAG, automation, agentic, PurchaseOrder, security/hardening and AI integration.
- `ai-service/` — FastAPI Applied AI service with P0 foundation plus P1–P4 LLM, RAG, automation and agentic features.
- `consumer_flutter/` — supplied consumer Flutter source scope (`lib/` plus the P6 dependency-bearing `pubspec.yaml`).
- `partner_portal/` — supplied Next.js portal with P5/P6 UI and PurchaseOrder workflow.
- `.github/workflows/backend-ci.yml` — CI workflow.
- Integration reports and setup notes.

## Important source boundary
The supplied consumer baseline was `consumer_flutter/lib/`, not a full Flutter platform project. Therefore `android/`, `ios/`, etc. are intentionally not fabricated. Keep the existing Flutter platform shell and apply the included `lib/` + `pubspec.yaml`.

## Final audit fixes in this package
- Spring Security internal RAG bridge corrected to the actual `/api/internal/ai/**` controller path.
- FCM background-handler registration moved after successful Firebase initialization.
- Legacy restock-request UI retained only as a non-calling deprecation page; active replenishment uses Purchase Orders.
- Portal documentation and Postman variable naming updated to the PurchaseOrder architecture.
- Generated Python bytecode/cache artifacts removed.

## Verification boundary
Python syntax, Compose YAML, Postman JSON and Java structural checks were performed in the packaging environment. Full Docker, Maven, Flutter and Next.js runtime/build verification was not possible because those toolchains were unavailable there. Run the Windows verification sequence in `README_INTEGRATED.md` before treating the package as runtime-verified.


See `FINAL_AUDIT.md` for the final concrete bug-fix and static-audit record.
