---
sidebar_position: 1
title: Using ZegoPrebuiltView
---

# Using ZegoPrebuiltView

`ZegoPrebuiltView` renders ZEGOCLOUD's JavaScript UIKit inside a Flutter `HtmlElementView`. The JS UIKit handles all video rendering, controls, and call logic in the browser DOM.

## Basic usage

```dart
import 'package:zegoweb_prebuilt/zegoweb_prebuilt.dart';

class CallPage extends StatefulWidget {
  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  ZegoUIKitPrebuilt? _prebuilt;

  @override
  void initState() {
    super.initState();
    _initCall();
  }

  Future<void> _initCall() async {
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

    setState(() => _prebuilt = prebuilt);
  }

  @override
  void dispose() {
    _prebuilt?.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_prebuilt == null) return const CircularProgressIndicator();
    return ZegoPrebuiltView(prebuilt: _prebuilt!);
  }
}
```

## How it works

1. `ZegoPrebuilt.loadScript()` injects the UIKit JavaScript
2. `ZegoPrebuilt.create(kitToken)` instantiates the JS UIKit
3. `joinRoom(config)` tells the UIKit to render into a DOM container
4. `ZegoPrebuiltView` creates an `HtmlElementView` pointing at that container
5. The JS UIKit handles everything: video tiles, controls, device selection

## Lifecycle

- Call `destroy()` when the widget is removed to clean up JS resources
- `hangUp()` leaves the call but keeps the instance alive for potential rejoin
- `destroy()` tears down the instance entirely
