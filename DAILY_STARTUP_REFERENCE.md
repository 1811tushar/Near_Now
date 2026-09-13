# NearNow — Daily Startup & Operations Reference

Keep this open in a tab. Every command below is copy-paste ready for PowerShell.

---

## 🐳 A. Docker — wake up the whole backend stack

Run from the project root (`NearNow_Complete_FINAL_Resolved\`):

```powershell
docker compose --profile monitoring up -d --build
```
Always use `--profile monitoring` — plain `docker compose up` silently skips Prometheus + Grafana.

**Verify everything is healthy:**
```powershell
docker compose ps
```
You must see **7** containers: `postgres`, `redis`, `ai-service`, `backend`, `portal`, `prometheus`, `grafana` — all `Up`/`healthy`.

**Stop everything (end of day):**
```powershell
docker compose --profile monitoring down
```
⚠️ Never add `-v` to this unless you WANT to wipe the database (products/users). `-v` deletes volumes.

**If something looks broken, check one service's logs:**
```powershell
docker compose logs backend --tail 100
docker compose logs ai-service --tail 100
```

---

## 🔎 B. Health checks — confirm before doing anything else

```powershell
Invoke-RestMethod http://localhost:8080/actuator/health   # backend -> {"status":"UP"}
Invoke-RestMethod http://localhost:8001/health              # ai-service -> {"status":"ok"}
```
Browser: `http://localhost:9090/targets` (Prometheus — `backend` target should be `UP`)
Browser: `http://localhost:3001` (Grafana — login screen)

---

## 📦 C. Seed the database (only needed on a FRESH/empty database)

```powershell
Invoke-RestMethod -Uri http://localhost:8080/api/admin/seed -Method POST -Headers @{ Authorization = "Bearer <admin-token>" }
```
Get `<admin-token>` via the login command in section E below.

---

## 🖥️ D. Partner Portal (Next.js) — Admin/Vendor/Warehouse web app

**Already running via Docker** at:
```
http://localhost:3000
```
No separate `npm run dev` needed unless you want local hot-reload (optional):
```powershell
cd partner_portal
npm install
npm run dev
```

---

## 📱 E. Flutter consumer app

```powershell
cd consumer_flutter
flutter devices                 # confirm an emulator/device is listed
flutter run                     # first run / after pulling new code
```
While it's running, in the SAME terminal:
- `r` = hot reload (fast, after small code edits)
- `R` = hot restart (after fixing a crash / config change)
- `q` = quit

If you ever see a `pub get` dependency conflict on `intl`, run:
```powershell
flutter pub add intl:^0.20.2
```

---

## 🔑 F. Test accounts (see CREDENTIALS.md for the full table)

| Role | Email | Password |
|---|---|---|
| Admin | admin@nearnow.com | Admin@123 |
| Vendor | vendor@nearnow.com | Vendor@123 |
| Warehouse Manager | warehouse@nearnow.com | Warehouse@123 |

Portal login: `http://localhost:3000/login`

---

## 🧪 G. Backend test suite

```powershell
cd backend
.\mvnw.cmd test "-Dtest=!OrderPlacementIntegrationTest"
```
(`OrderPlacementIntegrationTest` is excluded — documented Testcontainers/Docker-Desktop npipe issue on Windows, see `backend/README_INTEGRATED.md`.)

---

## ⚠️ H. Things that have bitten us before — check these first when something breaks

| Symptom | Likely cause |
|---|---|
| Flutter app: "No products found" everywhere | Database is fresh/empty — run section C (seed) |
| Flutter app: AI chat "connection abort" | `android/app/src/main/AndroidManifest.xml` is missing `android:usesCleartextTraffic="true"` on `<application>` — **this gets wiped every time you run `flutter create .`**, re-add it after |
| Flutter app: AI chat "Something went wrong" (generic) | Check `docker compose logs ai-service` — usually a Gemini API issue (see next row) |
| ai-service logs: `404 model ... no longer available` | Gemini model retired by Google — `.env` → `GEMINI_MODEL=gemini-flash-latest` |
| ai-service logs: `429 ResourceExhausted` | Gemini free-tier quota hit — wait ~60s (per-minute) or get a fresh API key (per-day) |
| Postgres: `no pg_hba.conf entry` on backend startup | Stale Docker volume from a previous run — `docker compose down -v` then `up --build` again (⚠️ wipes DB, re-seed after) |
| `docker compose up` only shows 5 containers | Forgot `--profile monitoring` |
| `flutter pub get` fails on `intl` version | Run `flutter pub add intl:^0.20.2` |
