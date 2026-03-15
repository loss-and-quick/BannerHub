# BannerHub

Rebuild pipeline for **GameHub 5.3.5 ReVanced** using apktool. Applies smali and resource patches to add a Component Manager, BCI launcher button, RTS touch controls, offline Steam launch skip, and UI tweaks directly inside GameHub.

## Features

### Component Manager
Accessible via GameHub's left side menu → **Components**.

- Lists all installed components from `files/usr/home/components/`
- **Add New Component** — inject a WCP or ZIP file as a brand new component slot; it appears in GameHub's DXVK / VKD3D / Box64 / FEXCore / GPU Driver selection menus immediately and persists across restarts
- **Inject file** — replace an existing component's contents with a new WCP or ZIP
- **Backup** — copies a component folder to `Downloads/BannerHub/{name}/`
- **Remove** — unregisters the component from GameHub's in-memory map and deletes the folder
- Supports ZIP (Turnip / adrenotools), zstd tar (DXVK, VKD3D, Box64), and XZ tar (FEXCore nightlies)
- FEXCore: flat extraction to component root; all other types preserve `system32/`+`syswow64/` structure
- Component folder cleared before every inject (no stale files); extraction runs on a background thread

### BCI Launcher Button
Tap the banner icon in GameHub's top-right toolbar to open **BannersComponentInjector** (`com.banner.inject`). Shows a toast if it is not installed.

### RTS Touch Controls
*Thanks to [@Nightwalker743](https://github.com/Nightwalker743) for making this possible!*

Accessible via **Settings → Controls tab** in the in-game sidebar overlay. Toggle on to enable a gesture overlay for PC/RTS games:

- **Tap to click** — moves cursor and left-clicks at tap position
- **Drag for box selection** — holds LMB during drag to draw a selection box
- **Long press for right-click** — 300ms hold triggers right-click
- **Double-tap for double-click** — two taps within 250ms / 50px
- **Two-finger pan** — camera pan (configurable)*
- **Pinch-to-zoom** — mouse wheel scroll (configurable)*
- **Gesture settings dialog** — customizable action picker for two-finger pan and pinch (gear icon in Controls tab)

*\*These two gestures can be customized in the RTS Gesture Settings menu.*

### Offline Steam Launch
When autoLogin fails and no network connection is available at cold start, the Steam login screen is skipped and the game launch pipeline proceeds using cached config. If network is available and autoLogin fails, the login screen is shown as normal.

### UI Tweaks
- "My" tab renamed to "My Games"
- EmuReady API toggle defaults to **off** on fresh installs (Advanced settings)

## How it works

1. The original APK is stored as a GitHub Release asset under the `base-apk` tag (GameHub 5.3.5 ReVanced Normal, 136 MB).
2. CI downloads it, decompiles with apktool, overlays everything in `patches/`, rebuilds, zipaligns, and signs.
3. The rebuilt APK is uploaded as a GitHub Release asset.

No external library injection — the Component Manager uses GameHub's own bundled libraries (commons-compress, zstd-jni, tukaani xz) via their correct runtime signatures.

## Installation

Download the APK matching your target package from the [latest stable release](https://github.com/The412Banner/bannerhub/releases/latest):

| APK | Package | Display Name |
|-----|---------|--------------|
| `Bannerhub-5.3.5-Revanced-Normal.apk` | `gamehub.lite` | GameHub Revanced |
| `Bannerhub-5.3.5-Revanced-PuBG.apk` | `com.tencent.ig` | GameHub Revanced PuBG |
| `Bannerhub-5.3.5-Revanced-AnTuTu.apk` | `com.antutu.ABenchMark` | GameHub Revanced AnTuTu |
| `Bannerhub-5.3.5-Revanced-alt-AnTuTu.apk` | `com.antutu.benchmark.full` | GameHub Revanced AnTuTu |
| `Bannerhub-5.3.5-Revanced-Ludashi.apk` | `com.ludashi.aibench` | GameHub Revanced Ludashi |
| `Bannerhub-5.3.5-Revanced-Genshin.apk` | `com.mihoyo.genshinimpact` | GameHub Revanced Genshin |
| `Bannerhub-5.3.5-Revanced-Original.apk` | `com.xiaoji.egggame` | GameHub Revanced |

All APKs are signed with AOSP testkey (v1/v2/v3). Each uses a unique package name and provider authority — multiple variants can be installed simultaneously without conflicts.

## Triggering a build

- Push a `v*` tag: `git tag v2.3.0 && git push origin refs/tags/v2.3.0`
- Or: **Actions → Build APK → Run workflow**

## Signing

Signed with AOSP testkey (`testkey.pk8` / `testkey.x509.pem`), v1 + v2 + v3 signatures.
