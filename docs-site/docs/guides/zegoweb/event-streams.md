---
sidebar_position: 4
title: Event Streams
---

# Event Streams

`ZegoEngine` exposes all SDK events as Dart broadcast `Stream`s. Subscribe with `.listen()` and cancel when done.

## Available events

### Room events

```dart
// Connection state changes
engine.onRoomStateChanged.listen((state) {
  switch (state) {
    case ZegoRoomState.connecting:
      print('Connecting...');
    case ZegoRoomState.connected:
      print('Connected');
    case ZegoRoomState.disconnected:
      print('Disconnected');
  }
});

// Users joining / leaving
engine.onRoomUserUpdate.listen((update) {
  if (update.type == ZegoUpdateType.add) {
    print('Users joined: ${update.users.map((u) => u.userName)}');
  } else {
    print('Users left: ${update.users.map((u) => u.userName)}');
  }
});

// Streams added / removed
engine.onRoomStreamUpdate.listen((update) {
  if (update.type == ZegoUpdateType.add) {
    for (final stream in update.streams) {
      // Start playing remote stream
    }
  }
});
```

### Device events

```dart
// Remote user toggled their camera
engine.onRemoteCameraStatusUpdate.listen((event) {
  print('${event.streamId} camera: ${event.enabled}');
});

// Remote user toggled their mic
engine.onRemoteMicStatusUpdate.listen((event) {
  print('${event.streamId} mic: ${event.enabled}');
});
```

### Audio events

```dart
// Per-stream volume levels (fires frequently when enabled)
engine.onSoundLevelUpdate.listen((levels) {
  for (final level in levels) {
    print('${level.streamId}: ${level.volume}');
  }
});

// Active speaker changed
engine.onActiveSpeakerChanged.listen((streamId) {
  print('Active speaker: $streamId');
});
```

### Error events

```dart
engine.onError.listen((error) {
  print('Async error: ${error.code} — ${error.message}');
});
```

## Best practices

- Subscribe to events **before** calling `loginRoom()` to avoid missing early events
- All streams are broadcast streams — multiple listeners are fine
- Events are automatically cleaned up when you call `engine.destroy()`
