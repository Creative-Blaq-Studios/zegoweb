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
| `userName` | `String?` | `null` | Display name |
| `layout` | `ZegoLayoutMode` | `auto` | Initial layout (grid, sidebar, pip, spotlight, gallery, auto) |
| `videoFit` | `BoxFit` | `contain` | How video streams fit within tiles |
| `showPreJoinView` | `bool` | `true` | Show camera preview before joining |
| `showMicrophoneToggle` | `bool` | `true` | Show mic button in controls bar |
| `showCameraToggle` | `bool` | `true` | Show camera button in controls bar |
| `showScreenShareButton` | `bool` | `false` | Show screen share button |
| `showLayoutPicker` | `bool` | `true` | Show layout picker button in controls bar |
| `hideNoVideoTiles` | `bool` | `false` | Initial state for hiding camera-off participants |
| `showAudioDebugOverlay` | `bool` | `false` | Show floating audio debug panel |

## Call states

`ZegoCallScreen` transitions through these states:

```
idle → preJoin → joining → inCall → leaving → idle
```

- **idle** — widget mounted, nothing happening yet
- **preJoin** — showing camera preview and device selection
- **joining** — joining the room and publishing local stream
- **inCall** — in the call, showing participants
- **leaving** — cleaning up streams and engine

## Logging

Enable lifecycle logging to see join/leave, stream add/remove, and error events in the console:

```dart
import 'package:zegoweb/zegoweb.dart';

ZegoWeb.setLogLevel(ZegoLogLevel.info);    // lifecycle events
ZegoWeb.setLogLevel(ZegoLogLevel.verbose); // everything
```
