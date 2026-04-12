# zegoweb monorepo

Unofficial community Flutter **web** plugins for ZEGOCLOUD's Express Video
SDK. Three packages live here:

> Not affiliated with or endorsed by ZEGOCLOUD. Wraps the official
> `zego-express-engine-webrtc` JavaScript SDK (and, for `zegoweb_prebuilt`,
> `@zegocloud/zego-uikit-prebuilt`).

## Packages

| Package | Role | Status |
|---|---|---|
| [`packages/zegoweb`](packages/zegoweb) | Core RTC wrapper — thin Dart API over the Express SDK | **active** |
| [`packages/zegoweb_prebuilt`](packages/zegoweb_prebuilt) | Thin wrap of `@zegocloud/zego-uikit-prebuilt` (DOM-based call UI) | **active** |
| [`packages/zegoweb_ui`](packages/zegoweb_ui) | Flutter-native opinionated call UI built on top of `zegoweb` | planned |

## Which package should I use?

| If you want… | Use | Why |
|---|---|---|
| Maximum control over video layout, widgets, and call flow, using Flutter widgets and your own state management | **`zegoweb`** | Raw RTC API. You write your own UI on top. |
| A drop-in, pre-built call UI with the minimum possible integration code, and you're okay with the UI being rendered by ZEGO's JS UIKit inside an `HtmlElementView` | **`zegoweb_prebuilt`** | Shortest time to a working call screen. Styling is limited to what the UIKit exposes. |
| A drop-in, pre-built call UI **rendered in Flutter widgets** (themeable, embeddable, composable with the rest of your Flutter tree) | **`zegoweb_ui`** | Native Flutter widgets, full theming, depends on `zegoweb`. Heavier than `zegoweb_prebuilt` but integrates seamlessly. |
| Mobile or desktop support | neither — use [`zego_express_engine`](https://pub.dev/packages/zego_express_engine) (official) | This monorepo is web-only. |

## Repository layout

```
zegoweb/
├─ packages/
│  ├─ zegoweb/             # core RTC wrapper (this is what ships first)
│  ├─ zegoweb_prebuilt/    # planned
│  └─ zegoweb_ui/          # planned
├─ melos.yaml
├─ pubspec.yaml            # workspace root
└─ README.md               # this file
```

## Development

```bash
dart pub global activate melos
melos bootstrap
melos run analyze
melos run test
```

See each package's own README for install and usage.

## License

See [`LICENSE`](LICENSE). The ZEGO Express Web SDK and the UIKit are
licensed separately by ZEGOCLOUD.
