# zegoweb

Unofficial community Flutter **web** plugin wrapping ZEGOCLOUD's
[`zego-express-engine-webrtc`](https://www.npmjs.com/package/zego-express-engine-webrtc)
JavaScript SDK.

> Not affiliated with or endorsed by ZEGOCLOUD. This plugin wraps the official
> `zego-express-engine-webrtc` JavaScript SDK and exposes an idiomatic Dart
> API. For mobile/desktop, use the official `zego_express_engine` plugin.

## Status

- Platforms: **web only**
- Supported Express SDK versions: **`^3.0.0`** (tested against 3.6.x)
- API surface: core RTC — engine lifecycle, rooms, local/remote streams,
  device enumeration, permissions, events. No effects, mixer, CDN, screen
  share, ZIM chat, or beauty features.

## Install

```bash
flutter pub add zegoweb
```

## Loading the JS SDK

Two options — pick one.

### Option A — manual `<script>` tag (recommended for production)

Add to `web/index.html` inside `<head>`:

```html
<script src="https://unpkg.com/zego-express-engine-webrtc@3.6.0/index.js"></script>
```

Pin a specific version. Works under strict CSP if you whitelist the CDN.

### Option B — dynamic injection

```dart
import 'package:zegoweb/zegoweb.dart';

await ZegoWeb.loadScript(version: '3.6.0');
```

Idempotent; safe to call multiple times. Good for prototyping.

## Minimal usage

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

  engine.onError.listen((e) => print('zego error: ${e.code} ${e.message}'));
  engine.onRoomStreamUpdate.listen((u) async {
    if (u.type == ZegoUpdateType.add) {
      for (final s in u.streams) {
        await engine.startPlaying(s.streamId);
      }
    }
  });

  await engine.loginRoom(
    'my-room',
    const ZegoUser(userId: 'user-1', userName: 'Alice'),
  );

  final local = await engine.createLocalStream();
  await engine.startPublishing('stream-user-1', local);

  // Render with: ZegoVideoView(stream: local)
}
```

See [`example/`](example/) for a full 1:1 call demo, token generation
patterns, and a real-SDK integration smoke test.

## Tokens

`ZegoEngineConfig.tokenProvider` is called on login and again on
`tokenWillExpire`. The plugin handles the refresh loop — you write the fetch
logic once. See [`example/README.md`](example/README.md) for three reference
patterns:

1. Dev / AppSign mode (empty token)
2. Temporary console token, or local `tool/generate_test_token.dart`
3. Serverless function (Supabase Edge or Firebase Callable reference
   implementations in `example/`)

## Permissions

`zegoweb` requires a secure context (HTTPS or `localhost`). `createEngine`
throws immediately otherwise. `engine.checkPermissions()` pre-flights
camera/mic permission where the browser exposes the Permissions API; Safari
returns `prompt` as a safe default.

## Testing

- `flutter test` — pure Dart units
- `flutter test --platform chrome` — interop tests against a fake JS SDK
- `flutter test integration_test/real_sdk_smoke_test.dart` (from `example/`)
  — gated by `--dart-define=ZEGO_APP_ID=...`

## License

See [`LICENSE`](LICENSE). Express SDK itself is licensed separately by
ZEGOCLOUD.
