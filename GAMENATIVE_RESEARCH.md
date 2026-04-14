# GameNative Research Log
**Source:** https://github.com/utkarshdalal/GameNative  
**Date:** 2026-04-14  
**Purpose:** API reference for BannerHub store feature jobs

---

## GOG

### GOG-1: Cloud Saves
**API base:** `https://cloudstorage.gog.com/v1/{userId}/{clientId}`
- List: `GET /v1/{userId}/{clientId}`
- Upload: `PUT /v1/{userId}/{clientId}/{dirname}/{relativePath}` — raw bytes, `Content-Type: application/octet-stream`
- Download: `GET /v1/{userId}/{clientId}/{dirname}/{relativePath}`

**Response (file list):**
```json
[{ "name": "dirname/path/file.sav", "hash": "md5", "last_modified": "2024-01-15T10:30:00Z" }]
```
**Sync logic:** compare local vs cloud `last_modified` timestamps → DOWNLOAD / UPLOAD / CONFLICT / NONE  
**Auth:** `Authorization: Bearer {accessToken}`  
**Source file:** `GOGCloudSavesManager.kt` (25 KB)

---

### GOG-2: Update Checker
**Status in GameNative:** Not fully implemented — DB schema stores `buildId`, `versionName`, `language` but no comparison logic.  
**What we use:** `content-system.gog.com/products/{id}/os/windows/builds?generation=2` → `items[0].build_id` ✅

---

### GOG-3: DLC Management
**Data model:**
```kotlin
data class GOGManifestMeta(
    val baseProductId: String,
    val products: List<Product>,   // base + DLCs
    val depots: List<Depot>
)
data class Product(
    val productId: String,
    val name: String,
    val postInstallExecutable: Executable?
)
```
**Detection:** `findDLCProducts()` excludes base game productId; `separateBaseDLC()` partitions files by `productId`  
**Download flow:** base game first → each DLC sequentially; continues on DLC failure  
**API:** `https://api.gog.com/products/{id}?expanded=downloads,description,screenshots` (note: `expanded` not `expand`)  
**Source file:** `GOGDownloadManager.kt` (74 KB), `GOGManifestParser.kt` (20 KB)

---

### GOG Auth (reference)
- Token URL: `https://auth.gog.com/token`
- Client ID: `46899977096215655`
- Client Secret: `9d85c43b1482497dbbce61f6e4aa173a433796eeae2ca8c5f6129f2dc4de46d9`
- Redirect URI: `https://embed.gog.com/on_login_success?origin=client`
- Refresh: 5-minute buffer before expiry

---

## Epic Games

### EPIC-1: Free Games
**Status in GameNative:** Not implemented. No freeGamesPromotions integration.  
**Endpoint to use:** `https://store-site-backend-static-ipv4.ak.epicgames.com/freeGamesPromotions?locale=en-US&country=US&allowCountries=US`  
**No auth needed for list.** Claim requires existing OAuth token → POST to order endpoint.

---

### EPIC-2: Cloud Saves
**API base:** `https://datastorage-public-service-liveegs.live.use1a.on.epicgames.com`
- List saves: `GET /api/v1/access/egstore/savesync/{accountId}/{appName}/`
- Get write links: `POST /api/v1/access/egstore/savesync/{accountId}/{appName}/` body: `{"files":["filename"]}`

**Response (list):**
```kotlin
data class CloudSaveFiles(
    val files: Map<String, CloudFileInfo>
)
data class CloudFileInfo(
    val hash: String,
    val lastModified: String,
    val readLink: String?,    // download URL
    val writeLink: String?    // upload URL (request via POST)
)
```
**Sync logic:** timestamp comparison → DOWNLOAD / UPLOAD / CONFLICT / NONE  
**Manifest:** binary chunked format — 66-byte header per chunk (magic, GUID, rolling hash, SHA-1, compression metadata)  
**Auth:** `Authorization: Bearer {accessToken}`, `Content-Type: application/json`  
**Source file:** `EpicCloudSavesManager.kt` (62 KB)

---

### EPIC-3: Update Checker
**Status in GameNative:** Partial — binary manifest parsed, chunk hashes/sizes verified, but no explicit version comparison logic.  
**What we use:** manifest assets/v2 `elements[0].buildVersion` as version identifier ✅  
**GameNative note:** existing chunks matching size+hash are skipped ("Chunk already exists and verified, skipping") — useful for delta updates.

---

### EPIC-4: DLC/Add-on Management
**Status in GameNative:** Implemented  
**Detection field:** `EpicGame.baseGameAppName` — non-empty = it's a DLC  
**Download flow:**
```kotlin
val dlcsToDownload = epicManager.getGamesById(dlcIds)
    .filter { dlcIds.contains(it.id) }
// Pre-fetch all DLC manifests → aggregate download size
// Download base first → each DLC sequentially
// Continue on DLC failure; track each independently
```
**Source file:** `EpicDownloadManager.kt` (48 KB)

---

### Epic Auth (reference)
- Token URL: `https://account-public-service-prod.ol.epicgames.com/account/api/oauth/token`
- Exchange URL: `https://account-public-service-prod.ol.epicgames.com/account/api/oauth/exchange`
- Client ID: `34a02cf8f4414e29b15921876da36f9a`
- Client Secret: `daafbccc737745039dffe53d94fc76cf`
- Redirect URI: `https://www.epicgames.com/id/api/redirect`
- User-Agent: `UELauncher/11.0.1-14907503+++Portal+Release-Live Windows/10.0.19041.1.256.64bit`
- Ownership token endpoint (DRM): `/ecommerceintegration/api/public/platforms/EPIC/identities/{accountId}/ownershipToken`

---

## Amazon Games

### AMAZON-1: Update Checker
**Status in GameNative:** Implemented  
**Method:** `AmazonApiClient.isUpdateAvailable(productId, currentVersionId, token)` — posts to GetLiveVersionIds  
**We use:** `getGameDownload(entitlementId).versionId` instead (more reliable) ✅  
**Source file:** `AmazonApiClient.kt` (16.5 KB)

---

### AMAZON-2: DLC Management
**Status in GameNative:** Not implemented  
**What exists:** `getEntitlements()` retrieves all with pagination; no type-based filtering  
**Entitlement endpoint:** `POST https://gaming.amazon.com/api/distribution/entitlements`  
**To implement:** filter by type ≠ GAME in GetEntitlements response; associate DLC with parent productId; install via same manifest pipeline  
**Key field to check in entitlement JSON:** `product.productType` or similar type discriminator (GameNative filters only `GAME` type currently)

---

### Amazon Auth (reference)
- Token URL: `https://api.amazon.com/auth/token`
- Register: `https://api.amazon.com/auth/register`
- Device Type: `A2UMVHOX7UP4V7`
- Marketplace ID: `ATVPDKIKX0DER`
- Gaming Key ID: `d5dc8b8b-86c8-4fc4-ae93-18c0def5314d` (same as BannerHub ✅)
- Launcher Channel ID: `87d38116-4cbf-4af0-a371-a5b498975346` (same as BannerHub ✅)
- Scope: `device_auth_access`, Response type: `code`

---

## General Notes

- **Token refresh buffer:** All 3 stores use 5-minute buffer before expiry — matches BannerHub
- **Epic CDN:** GameNative filters out Cloudflare CDN URLs (use non-CF CDN) — already handled in BannerHub
- **GOG language codes:** 28 languages mapped to GOG manifest codes — only `*`/`en`/`en-US`/`english` needed for English-only
- **Amazon protobuf:** Wire type + varint encoding — already implemented in BannerHub's `AmazonManifest.java`
- **Epic chunk skip:** Re-installs can skip already-verified chunks (size+SHA-1 match) — useful for update optimization later
- **GOG `expanded` param:** GameNative uses `expanded=` not `expand=` — may need testing if we extend product API calls
