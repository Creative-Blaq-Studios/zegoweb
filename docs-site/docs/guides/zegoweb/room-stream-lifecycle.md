---
sidebar_position: 1
title: Room & Stream Lifecycle
---

# Room & Stream Lifecycle

The typical lifecycle of a video call using `zegoweb`:

```
createEngine → loginRoom → createLocalStream → startPublishing
                              ↕
                         startPlaying (remote streams)
                              ↕
stopPublishing → destroyStream → logoutRoom → destroy
```

## 1. Create the engine

```dart
final engine = await ZegoWeb.createEngine(
  ZegoEngineConfig(
    appId: 123456789,
    server: 'wss://webliveroom-api.zego.im/ws',
    scenario: ZegoScenario.communication,
    tokenProvider: () async => await fetchToken(),
  ),
);
```

The engine is your connection to ZEGOCLOUD. Create it once, reuse it for the session.

## 2. Set up event listeners (before joining)

Always subscribe to events **before** calling `loginRoom()`, so you don't miss any:

```dart
engine.onRoomStreamUpdate.listen((update) async {
  if (update.type == ZegoUpdateType.add) {
    for (final stream in update.streams) {
      final remote = await engine.startPlaying(stream.streamId);
      // Store remote stream, render with ZegoVideoView
    }
  } else {
    for (final stream in update.streams) {
      await engine.stopPlaying(stream.streamId);
    }
  }
});

engine.onRoomUserUpdate.listen((update) {
  // Track who's in the room
});

engine.onRoomStateChanged.listen((state) {
  // Handle connection state changes
});
```

## 3. Join the room

```dart
await engine.loginRoom(
  'my-room',
  const ZegoUser(userId: 'user-1', userName: 'Alice'),
);
```

The `tokenProvider` you set in `ZegoEngineConfig` is called automatically to get the auth token.

## 4. Publish your local stream

```dart
final localStream = await engine.createLocalStream(
  ZegoStreamConfig(
    camera: true,
    microphone: true,
  ),
);

await engine.startPublishing('stream-user-1', localStream);
```

Other participants will receive your stream via their `onRoomStreamUpdate` listener.

## 5. Render video

Use `ZegoVideoView` to render any stream (local or remote):

```dart
ZegoVideoView(stream: localStream)
ZegoVideoView(stream: remoteStream)
```

## 6. Leave the call

```dart
await engine.stopPublishing('stream-user-1');
engine.destroyStream(localStream);
await engine.logoutRoom();
engine.destroy();
```

Always clean up in this order: stop publishing → destroy local stream → logout → destroy engine.
