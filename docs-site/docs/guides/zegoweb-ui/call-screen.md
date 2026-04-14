---
sidebar_position: 1
title: Using ZegoCallScreen
---

# Using ZegoCallScreen

`ZegoCallScreen` is the main entry point for `zegoweb_ui`. It manages the entire call lifecycle: pre-join preview, connecting, in-call video, and leaving.

## Basic usage

```dart
import 'package:zegoweb/zegoweb.dart';
import 'package:zegoweb_ui/zegoweb_ui.dart';

ZegoCallScreen(
  engineConfig: ZegoEngineConfig(
    appId: 123456789,
    server: 'wss://webliveroom-api.zego.im/ws',
    scenario: ZegoScenario.communication,
    tokenProvider: () async => await fetchToken(),
  ),
  callConfig: ZegoCallConfig(
    roomId: 'my-room',
    userId: 'user-1',
    userName: 'Alice',
  ),
  onCallEnded: () => Navigator.pop(context),
)
```

## ZegoCallConfig options

| Property | Type | Default | Description |
|---|---|---|---|
| `roomId` | `String` | required | Room identifier |
| `userId` | `String` | required | User identifier |
| `userName` | `String` | required | Display name |
| `layoutMode` | `ZegoLayoutMode` | `grid` | Initial layout (grid, sidebar, pip) |
| `debugMode` | `bool` | `false` | Show audio debug overlay |

## Call states

`ZegoCallScreen` transitions through these states:

```
idle → preJoin → connecting → connected → leaving → idle
```

- **idle** — widget mounted, nothing happening yet
- **preJoin** — showing camera preview and device selection
- **connecting** — joining the room and publishing local stream
- **connected** — in the call, showing participants
- **leaving** — cleaning up streams and engine
