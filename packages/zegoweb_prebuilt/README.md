# zegoweb_prebuilt

Unofficial community Flutter **web** plugin wrapping ZEGOCLOUD's
[`@zegocloud/zego-uikit-prebuilt`](https://www.npmjs.com/package/@zegocloud/zego-uikit-prebuilt)
JavaScript UIKit.

> Not affiliated with or endorsed by ZEGOCLOUD. This plugin wraps the official
> prebuilt UIKit and exposes an idiomatic Dart API with a single Flutter
> widget. For a fully Flutter-native call UI, see `zegoweb_ui`.

**[Full documentation](../../docs-site/)**

## Status

- Platforms: **web only**
- API surface: `ZegoPrebuilt` (entry class), `ZegoPrebuiltConfig` (17 typed
  fields + `rawConfig` escape hatch), `ZegoPrebuiltView` (widget), 5 event
  streams, 2 token helpers.

## Install

```bash
flutter pub add zegoweb_prebuilt
```

## Loading the JS UIKit

Two options — pick one.

### Option A — manual `<script>` tag (recommended for production)

Add to `web/index.html` inside `<head>`:

```html
<script src="https://unpkg.com/@zegocloud/zego-uikit-prebuilt@2.17.3/zego-uikit-prebuilt.js"></script>
```

Pin a specific version.

### Option B — dynamic injection

```dart
import 'package:zegoweb_prebuilt/zegoweb_prebuilt.dart';

await ZegoPrebuilt.loadScript(version: '2.17.3');
```

Idempotent; safe to call multiple times.

## Minimal usage

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

  // Mount in your widget tree:
  // ZegoPrebuiltView(prebuilt: prebuilt)
  //
  // Tear down when done:
  // await prebuilt.destroy();
}
```

See [`example/`](example/) for a full 1:1 call demo.

## Testing

- `flutter test` — pure Dart model tests
- `flutter test --platform chrome` — interop tests against a fake UIKit
- `flutter test integration_test/...` (from `example/`) — gated by
  `--dart-define=ZEGO_APP_ID=...`

## License

See [`LICENSE`](LICENSE). The UIKit itself is licensed separately by ZEGOCLOUD.
