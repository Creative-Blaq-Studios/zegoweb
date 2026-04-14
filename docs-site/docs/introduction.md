---
slug: /introduction
sidebar_position: 1
title: Introduction
---

# Zegoweb

Unofficial community Flutter **web** plugins for [ZEGOCLOUD's](https://www.zegocloud.com) Express Video SDK.

> Not affiliated with or endorsed by ZEGOCLOUD. These plugins wrap the official JavaScript SDKs and expose idiomatic Dart APIs.

## What is this?

Zegoweb is a monorepo containing three Flutter web packages that let you add real-time video calls to a Flutter web app using ZEGOCLOUD's infrastructure:

| Package | What it does |
|---|---|
| **`zegoweb`** | Core RTC wrapper — a thin, idiomatic Dart API over the `zego-express-engine-webrtc` JavaScript SDK. You get rooms, streams, devices, events, and full control. You build your own UI. |
| **`zegoweb_ui`** | A complete, Flutter-native call UI built on top of `zegoweb`. Drop in `ZegoCallScreen` and get a pre-join view, video grid, controls bar, device selection — all rendered as Flutter widgets you can theme. |
| **`zegoweb_prebuilt`** | A thin wrapper around ZEGOCLOUD's `@zegocloud/zego-uikit-prebuilt` JavaScript UIKit. Renders inside an `HtmlElementView`. Fastest path to a working call, but limited styling. |

## Which package should I use?

| If you want… | Use | Why |
|---|---|---|
| Maximum control over video layout and call flow | **`zegoweb`** | Raw RTC API. You build your own widgets and state management on top. |
| A drop-in call UI rendered as Flutter widgets, with theming and layout options | **`zegoweb_ui`** | Native Flutter widgets, full `ThemeExtension` support. Depends on `zegoweb`. |
| A drop-in call UI with the minimum possible code, and you're okay with DOM-based rendering | **`zegoweb_prebuilt`** | Wraps ZEGO's JS UIKit. Shortest path to a working call. Styling limited to what the UIKit exposes. |
| Mobile or desktop support | **None of these** — use [`zego_express_engine`](https://pub.dev/packages/zego_express_engine) (official) | This monorepo is **web only**. |

## How the packages relate

```
┌─────────────────────┐
│   zegoweb_prebuilt   │  ← wraps @zegocloud/zego-uikit-prebuilt JS UIKit
│   (standalone)       │     (independent, does not depend on zegoweb)
└─────────────────────┘

┌─────────────────────┐
│     zegoweb_ui       │  ← Flutter-native call UI
│  (depends on zegoweb)│
└──────────┬──────────┘
           │ uses
┌──────────▼──────────┐
│      zegoweb         │  ← Core RTC wrapper
│ (wraps JS Express SDK)│
└─────────────────────┘
```

- **`zegoweb`** is the foundation. It handles all communication with the ZEGO JavaScript SDK through Dart's JS interop layer.
- **`zegoweb_ui`** depends on `zegoweb` and builds a complete call experience with Flutter widgets.
- **`zegoweb_prebuilt`** is independent — it wraps a completely different JavaScript package and renders via the browser's DOM.
