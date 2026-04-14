---
sidebar_position: 3
title: Quick Start
---

# Quick Start

Minimal working examples for each package.

## zegoweb — Core RTC

Full control. You manage the UI.

```dart
import 'package:zegoweb/zegoweb.dart';

Future<void> joinCall() async {
  await ZegoWeb.loadScript();

  final engine = await ZegoWeb.createEngine(
    ZegoEngineConfig(
      appId: 123456789,
      server: 'wss://webliveroom-api.zego.im/ws',
      scenario: ZegoScenario.communication,
      tokenProvider: () async => await fetchTokenFromMyBackend(),
    ),
  );

  // Listen for remote streams
  engine.onRoomStreamUpdate.listen((update) async {
    if (update.type == ZegoUpdateType.add) {
      for (final stream in update.streams) {
        await engine.startPlaying(stream.streamId);
      }
    }
  });

  // Join room
  await engine.loginRoom(
    'my-room',
    const ZegoUser(userId: 'user-1', userName: 'Alice'),
  );

  // Publish local stream
  final local = await engine.createLocalStream();
  await engine.startPublishing('stream-user-1', local);

  // Render with ZegoVideoView(stream: local)
}
```

## zegoweb_ui — Flutter-Native Call UI

Drop-in widget. Handles the full call lifecycle.

```dart
import 'package:zegoweb/zegoweb.dart';
import 'package:zegoweb_ui/zegoweb_ui.dart';

Navigator.push(context, MaterialPageRoute(
  builder: (_) => ZegoCallScreen(
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
  ),
));
```

## zegoweb_prebuilt — UIKit Wrapper

Fastest path. DOM-based rendering via ZEGO's JavaScript UIKit.

```dart
import 'package:zegoweb_prebuilt/zegoweb_prebuilt.dart';

Future<void> startCall() async {
  await ZegoPrebuilt.loadScript();

  final kitToken = ZegoPrebuilt.generateTestKitToken(
    appId: 123456789,
    serverSecret: 'your-server-secret',
    roomId: 'my-room',
    userId: 'user-1',
    userName: 'Alice',
  );

  final prebuilt = await ZegoPrebuilt.create(kitToken);

  prebuilt.onLeaveRoom.listen((_) => Navigator.pop(context));

  await prebuilt.joinRoom(ZegoPrebuiltConfig(
    roomId: 'my-room',
    userId: 'user-1',
    userName: 'Alice',
  ));

  // Render with ZegoPrebuiltView(prebuilt: prebuilt)
}
```

:::tip
Each package has a full example app. Clone the repo and run:
```bash
cd packages/zegoweb/example && flutter run -d chrome
cd packages/zegoweb_ui/example && flutter run -d chrome
cd packages/zegoweb_prebuilt/example && flutter run -d chrome
```
:::
