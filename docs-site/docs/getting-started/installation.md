---
sidebar_position: 2
title: Installation
---

# Installation

Install the package you need. If you're unsure which one, see the [decision guide](/introduction#which-package-should-i-use).

## zegoweb (Core)

```bash
flutter pub add zegoweb
```

## zegoweb_ui (Flutter UI)

```bash
flutter pub add zegoweb_ui
```

This also installs `zegoweb` as a transitive dependency.

## zegoweb_prebuilt (UIKit Wrapper)

```bash
flutter pub add zegoweb_prebuilt
```

---

## Loading the JavaScript SDK

Each package wraps a different JavaScript library that must be loaded before use. You have two options:

### Option A: Manual `<script>` tag (recommended for production)

Add to your `web/index.html` inside `<head>`:

**For `zegoweb` / `zegoweb_ui`:**
```html
<script src="https://unpkg.com/zego-express-engine-webrtc@3.6.0/index.js"></script>
```

**For `zegoweb_prebuilt`:**
```html
<script src="https://unpkg.com/@zegocloud/zego-uikit-prebuilt@2.17.3/zego-uikit-prebuilt.js"></script>
```

Pin a specific version. Works under strict CSP if you whitelist the CDN.

### Option B: Dynamic injection (good for prototyping)

```dart
// For zegoweb / zegoweb_ui:
await ZegoWeb.loadScript(version: '3.6.0');

// For zegoweb_prebuilt:
await ZegoPrebuilt.loadScript(version: '2.17.3');
```

Both are idempotent — safe to call multiple times. The script is injected once and reused.
