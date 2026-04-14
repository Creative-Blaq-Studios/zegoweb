---
sidebar_position: 1
title: Prerequisites
---

# Prerequisites

Before using any zegoweb package, you need:

## Flutter SDK

- Flutter **≥ 3.22.0** with Dart **≥ 3.4.0**
- Web platform enabled (`flutter config --enable-web`)

## ZEGOCLOUD Account

1. Sign up at [zegocloud.com](https://www.zegocloud.com)
2. Create a project in the [ZEGOCLOUD Console](https://console.zegocloud.com)
3. Note your **AppID** and **Server URL** (for `zegoweb` / `zegoweb_ui`) or **ServerSecret** (for `zegoweb_prebuilt`)

:::caution Production tokens
For production, generate tokens on your backend server — never ship your ServerSecret in client code. See [Token Handling](/guides/zegoweb/token-handling) for details.
:::

## Secure Context (HTTPS)

All packages require a **secure context** — either `https://` or `http://localhost`. This is a browser requirement for accessing cameras and microphones, not a zegoweb limitation.

- `flutter run -d chrome` serves on `localhost` by default — this works.
- Deployed apps must use HTTPS.
- `zegoweb` throws a `ZegoStateError` immediately if `window.isSecureContext` is `false`.

## Browser Support

| Browser | Status |
|---|---|
| Chrome 80+ | Fully supported |
| Firefox 78+ | Fully supported |
| Edge 80+ | Fully supported (Chromium-based) |
| Safari 14+ | Supported, with caveats (see [Troubleshooting](/troubleshooting)) |
