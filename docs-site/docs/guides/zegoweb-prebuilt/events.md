---
sidebar_position: 3
title: Events & Callbacks
---

# Events & Callbacks

`ZegoUIKitPrebuilt` exposes five event streams:

| Event | Fires when |
|---|---|
| `onLeaveRoom` | The local user leaves the room (via hang up or API call) |
| `onUserJoin` | A remote user joins the room |
| `onUserLeave` | A remote user leaves the room |
| `onUserCountOrPropertyChanged` | The participant count changes or a user property updates |
| `onLiveStart` | A live broadcast begins (broadcast scenario only) |

## Usage

```dart
final prebuilt = await ZegoPrebuilt.create(kitToken);

prebuilt.onLeaveRoom.listen((_) {
  Navigator.pop(context);
});

prebuilt.onUserJoin.listen((users) {
  print('Users joined: ${users.length}');
});

prebuilt.onUserLeave.listen((users) {
  print('Users left: ${users.length}');
});
```

## Runtime controls

```dart
// Leave the call
await prebuilt.hangUp();

// Switch UI language at runtime
prebuilt.setLanguage(ZegoPrebuiltLanguage.chineseSimplified);

// Tear down the instance
await prebuilt.destroy();
```
