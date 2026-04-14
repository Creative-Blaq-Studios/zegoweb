---
sidebar_position: 3
title: Theming & Customization
---

# Theming & Customization

`zegoweb_ui` uses a `ThemeExtension<ZegoCallTheme>` for styling. If no extension is provided, it falls back to your app's `ColorScheme`.

## Using ZegoCallTheme

Add the extension to your app's theme:

```dart
MaterialApp(
  theme: ThemeData(
    extensions: [
      ZegoCallTheme(
        backgroundColor: Colors.grey[900]!,
        tileBackgroundColor: Colors.grey[800]!,
        controlsBarColor: Colors.black87,
        activeControlColor: Colors.white,
        inactiveControlColor: Colors.grey,
        dangerColor: Colors.red,
        textColor: Colors.white,
      ),
    ],
  ),
  // ...
)
```

## Fallback behavior

If you don't provide a `ZegoCallTheme`, the widgets read colors from your `ColorScheme`:

| ZegoCallTheme property | Fallback |
|---|---|
| `backgroundColor` | `colorScheme.surface` |
| `controlsBarColor` | `colorScheme.surfaceContainer` |
| `activeControlColor` | `colorScheme.onSurface` |
| `dangerColor` | `colorScheme.error` |
| `textColor` | `colorScheme.onSurface` |

This means `zegoweb_ui` looks reasonable with any Material theme out of the box.
