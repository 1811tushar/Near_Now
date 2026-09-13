# NearNow — Local Test Credentials & Setup Commands

⚠️ Local development only. Never use these values in a deployed environment.

## Portal URL
```
http://localhost:3000/login
```

## Step 1 — Register the two missing test accounts

Run each of these once (PowerShell, backend must already be up on :8080):

```powershell
Invoke-RestMethod -Uri http://localhost:8080/api/auth/register -Method POST -ContentType "application/json" -Body '{"email":"vendor@nearnow.com","password":"Vendor@123","fullName":"Test Vendor"}'

Invoke-RestMethod -Uri http://localhost:8080/api/auth/register -Method POST -ContentType "application/json" -Body '{"email":"warehouse@nearnow.com","password":"Warehouse@123","fullName":"Test Warehouse Manager"}'
```

## Step 2 — Promote both to their roles (direct DB update, same pattern used for admin)

```powershell
docker exec -it nearnow_complete_final_resolved-postgres-1 psql -U postgres -d nearnow_db -c "UPDATE users SET role='vendor' WHERE email='vendor@nearnow.com';"

docker exec -it nearnow_complete_final_resolved-postgres-1 psql -U postgres -d nearnow_db -c "UPDATE users SET role='warehouse_manager' WHERE email='warehouse@nearnow.com';"
```

## Step 3 — Vendor: create the vendor business profile (required before the Vendor portal tabs work)

```powershell
$vendorLogin = Invoke-RestMethod -Uri http://localhost:8080/api/auth/login -Method POST -ContentType "application/json" -Body '{"email":"vendor@nearnow.com","password":"Vendor@123"}'

Invoke-RestMethod -Uri http://localhost:8080/api/admin/vendors -Method POST -Headers @{ Authorization = "Bearer $($adminLogin.data.token)" } -ContentType "application/json" -Body '{"userId":<vendor-user-id-from-step-1-response>,"businessName":"Test Vendor Co","businessAddress":"123 Test St","gstNumber":"GST123456"}'
```
Note: newly created vendor profiles start **inactive** by design (pending admin approval) — go to the Partner Portal's **Pending Vendor Reviews** tab as admin and approve it, or it'll show as inactive.

## Step 4 — Warehouse manager: assign them to a store (required before warehouse tabs show data)

Use the admin token to call the store-assignment endpoint (`AdminStoreService`) with the warehouse manager's `userId` — check `backend/docs/PHASE18_WAREHOUSE.md` for the exact request shape, since this is a one-time bootstrap step documented there.

---

## Reference table

| Role | Email | Password | Portal landing page |
|---|---|---|---|
| Admin | admin@nearnow.com | Admin@123 | `/admin` |
| Vendor | vendor@nearnow.com | Vendor@123 | `/vendor` |
| Warehouse Manager | warehouse@nearnow.com | Warehouse@123 | `/warehouse` |

The portal reads a `nearnow_role` cookie to decide which section to route you into — this is set automatically by the login API route when you sign in with the right account.
