# NearNow — Run Now (Windows + PowerShell)

## 1. Open the correct folder

Open the folder containing:

- `docker-compose.yml`
- `backend/`
- `ai-service/`
- `partner_portal/`
- `consumer_flutter/`

In VS Code: **File → Open Folder** and select that `NearNow_Complete` folder.

## 2. Optional: create your own local environment file

From PowerShell in the project root:

```powershell
Copy-Item .env.example .env
```

You can leave the development fallback values in Compose for the first boot, but use your own `JWT_SECRET`, `DB_PASSWORD`, and `INTERNAL_API_KEY` for anything beyond a throwaway local demo. Add a Gemini key only if you want live Gemini-backed features.

## 3. Validate Compose before building

```powershell
docker compose config
```

Expected: Compose prints the resolved services without `no configuration file provided`, YAML errors, or missing-file errors.

## 4. Build and start the complete stack

```powershell
docker compose up -d --build
```

The first build can take several minutes because Maven, npm and Python dependencies are downloaded.

## 5. Check containers

```powershell
docker compose ps
```

You should see:

- `postgres`
- `redis`
- `ai-service`
- `backend`
- `portal`

The backend/portal start only after their health dependencies are ready.

## 6. Health checks

```powershell
curl.exe http://localhost:8001/health
curl.exe http://localhost:8080/actuator/health
```

Expected AI response:

```json
{"status":"ok"}
```

Expected backend health response contains `"status":"UP"`.

## 7. Open the portal

Open:

`http://localhost:3000`

The home route redirects to the login page.

## 8. Important: seed demo data

The seed endpoint exists only under the development profile. The Compose setup defaults to the development profile.

After backend is healthy, use the portal's **Admin → Seed demo data** page, or call the endpoint from an authenticated admin session.

## 9. If a build fails

Do not delete random project files. Capture the **first actual error**, not the final `exit code: 1` summary.

Useful commands:

```powershell
docker compose logs --tail 120 portal
docker compose logs --tail 120 backend
docker compose logs --tail 120 ai-service
```

If only the portal failed, rebuild it after the source fix:

```powershell
docker compose build --no-cache portal
docker compose up -d portal
```

## 10. Flutter

This package contains the supplied Flutter source scope (`lib/` plus `pubspec.yaml`). If your original Flutter project has the normal Android/iOS platform directories, keep those platform directories and replace/apply the supplied `lib/` and `pubspec.yaml`.

## 11. After this final repair archive

From the directory that directly contains `docker-compose.yml`:

```powershell
docker compose down
docker compose config
docker compose up -d --build
```

If Docker still reports an old cached compile error, force a clean rebuild of the affected services:

```powershell
docker compose build --no-cache backend portal ai-service
docker compose up -d
```

Then verify:

```powershell
docker compose ps
curl.exe http://localhost:8001/health
curl.exe http://localhost:8080/actuator/health
```

If a service fails, capture only the first meaningful error from:

```powershell
docker compose logs --tail 160 backend
```

or:

```powershell
docker compose logs --tail 160 portal
```

Do not run `docker compose` from `C:\Users\rai44` or another parent directory; Compose must be run from the folder containing this project's `docker-compose.yml` (or with `-f` pointing to it).
