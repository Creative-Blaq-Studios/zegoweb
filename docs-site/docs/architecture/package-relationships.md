---
sidebar_position: 1
title: Package Relationships
---

# Package Relationships

The monorepo contains three packages at different levels of abstraction.

## Dependency graph

```
zegoweb_prebuilt (standalone)
  └─ wraps: @zegocloud/zego-uikit-prebuilt (JS)

zegoweb_ui
  └─ depends on: zegoweb
      └─ wraps: zego-express-engine-webrtc (JS)
```

## What each package wraps

### zegoweb (Core)

**Wraps:** `zego-express-engine-webrtc` ^3.0.0 (the ZEGO Express Web SDK)

This is the foundation layer. It provides:
- A `ZegoEngine` class that maps to the JS SDK's `ZegoExpressEngine`
- Dart `Stream`s for every SDK event (room state, user updates, stream updates, etc.)
- `Future`-based async methods (converted from JS Promises)
- Typed error hierarchy (`ZegoError`, `ZegoPermissionException`, etc.)
- Device enumeration and switching
- Token refresh lifecycle management

`zegoweb` does **not** provide any UI — you build that yourself with Flutter widgets.

### zegoweb_ui (Flutter UI)

**Wraps:** `zegoweb` (the core package above)

Builds a complete call experience using Flutter widgets:
- `ZegoCallScreen` — drop-in widget that manages the entire call lifecycle
- `ZegoPreJoinView` — camera/mic preview before joining
- Layout widgets: `ZegoGridLayout`, `ZegoSidebarLayout`, `ZegoPipLayout`
- `ZegoControlsBar` — mute, camera, hang up, device selection
- `ZegoCallTheme` — `ThemeExtension` for consistent styling

Everything is a Flutter widget. You can embed, theme, and compose these with the rest of your widget tree.

### zegoweb_prebuilt (UIKit Wrapper)

**Wraps:** `@zegocloud/zego-uikit-prebuilt` ^2.17.3 (ZEGO's prebuilt JavaScript UIKit)

This is **independent** of `zegoweb`. It wraps a different JavaScript library that provides its own UI rendered in the browser's DOM:
- `ZegoPrebuiltView` renders inside an `HtmlElementView`
- Configuration maps to the JS UIKit's options (scenario, layout, resolution, language)
- Minimal Dart code needed — the JS UIKit handles most of the call logic

The trade-off: fast integration but limited styling control. The UI looks like ZEGO's default UIKit, not like your Flutter app.

## Why three packages?

Different use cases need different levels of control:

| Need | Package | Trade-off |
|---|---|---|
| "I want to build my own call UI from scratch" | `zegoweb` | Maximum flexibility, most code to write |
| "I want a ready-made call UI that looks like my Flutter app" | `zegoweb_ui` | Good balance of convenience and customization |
| "I want a working call in 10 lines of code" | `zegoweb_prebuilt` | Fastest setup, least control over appearance |
