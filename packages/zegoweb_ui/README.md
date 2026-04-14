# zegoweb_ui

Flutter-native call UI built on [`zegoweb`](../zegoweb) core.

> Not affiliated with or endorsed by ZEGOCLOUD.

**[Full documentation](https://creative-blaq-studios.github.io/zegoweb/)**

## Status

- Platforms: **web only**
- Depends on: `zegoweb` (core RTC wrapper)
- Layouts: Grid (full-width reflow), Sidebar (speaker + sidebar), PiP (floating self-view)
- Theming: `ThemeExtension<ZegoCallTheme>` with `ColorScheme` fallbacks

## Install

```bash
flutter pub add zegoweb_ui
```

## Quick Start

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

See [`example/`](example/) for a full demo.

## License

See [`LICENSE`](LICENSE).
