---
sidebar_position: 3
title: Key Concepts
---

# Key Concepts

Core concepts you'll encounter across all zegoweb packages.

## Engine

The `ZegoEngine` is the central object in `zegoweb`. It represents a connection to ZEGOCLOUD's infrastructure and manages:
- Room lifecycle (login/logout)
- Local stream capture (camera + microphone)
- Publishing your stream to others
- Playing remote streams
- Device enumeration and switching
- Event subscriptions

Create one with `ZegoWeb.createEngine(config)`. Dispose it when done.

## Room

A room is a virtual space where participants meet. Every participant in the same room can see and hear each other's published streams. Rooms are identified by a string `roomId`.

- `engine.loginRoom(roomId, user)` — join a room
- `engine.logoutRoom()` — leave the room
- Users and streams come and go — listen to `onRoomUserUpdate` and `onRoomStreamUpdate`

## Streams

A **stream** is a media feed — video and/or audio.

- **Local stream** (`ZegoLocalStream`): your camera and microphone. Created with `engine.createLocalStream()`.
- **Remote stream** (`ZegoRemoteStream`): another participant's media. Received via `onRoomStreamUpdate` and played with `engine.startPlaying(streamId)`.

Each stream is identified by a `streamId` string. Render any stream with the `ZegoVideoView(stream: stream)` widget.

## Publishing & Playing

- **Publishing** sends your local stream to the room: `engine.startPublishing(streamId, localStream)`
- **Playing** receives a remote stream: `engine.startPlaying(streamId)` — returns a `ZegoRemoteStream`

## Tokens

Tokens authenticate users with ZEGOCLOUD's servers. The flow:

1. Your app calls `tokenProvider()` (a callback you supply in `ZegoEngineConfig`)
2. Your backend generates a token using your AppID + ServerSecret
3. The token is passed to the SDK on `loginRoom()`
4. When the token is about to expire, the SDK fires `tokenWillExpire` → your `tokenProvider` is called again automatically

:::danger Never ship your ServerSecret
`generateTestKitToken()` and local token generation are for development only. In production, always generate tokens on your server.
:::

## Events

`ZegoEngine` exposes events as Dart `Stream`s. Subscribe with `.listen()`:

| Event | Fires when |
|---|---|
| `onRoomStateChanged` | Connection state changes (connecting, connected, disconnected) |
| `onRoomUserUpdate` | A user joins or leaves the room |
| `onRoomStreamUpdate` | A stream is added or removed |
| `onSoundLevelUpdate` | Audio volume levels update (per stream) |
| `onRemoteCameraStatusUpdate` | A remote user toggles their camera |
| `onRemoteMicStatusUpdate` | A remote user toggles their mic |
| `onActiveSpeakerChanged` | The loudest speaker changes |
| `onError` | An async error occurs |

## Permissions

Accessing camera and microphone requires browser permission. `zegoweb` checks this via the browser's Permissions API:

- `ZegoPermissionStatus.granted` — already allowed
- `ZegoPermissionStatus.prompt` — browser will ask the user (Safari always returns this)
- `ZegoPermissionStatus.denied` — user blocked access
- `ZegoPermissionStatus.unavailable` — API not available (use `prompt` as fallback)

If permission is denied, `createLocalStream()` throws a `ZegoPermissionException`.
