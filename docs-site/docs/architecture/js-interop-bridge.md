---
sidebar_position: 2
title: JS Interop Bridge
---

# JS Interop Bridge

The core `zegoweb` package communicates with ZEGOCLOUD's JavaScript SDK through a bridge layer built on Dart's `dart:js_interop`. This page explains how that bridge works.

## Overview

```
Your Flutter app
       │
       ▼
  ZegoEngine (Dart)          ← Public API: Futures, Streams, typed errors
       │
       ├── event_bridge.dart  ← JS callbacks → Dart Streams
       ├── promise_adapter.dart ← JS Promises → Dart Futures
       ├── zego_js.dart       ← @JS bindings to the Express SDK
       └── sdk_loader.dart    ← Dynamic <script> injection
       │
       ▼
  ZegoExpressEngine (JS)     ← The actual ZEGO JavaScript SDK
```

## The interop layer

Located in `zegoweb/lib/src/interop/`:

### `zego_js.dart` — JS type bindings

Uses `dart:js_interop` extension types to bind Dart types to the JavaScript SDK's global `ZegoExpressEngine` class:

```dart
@JS('ZegoExpressEngine')
extension type ZegoExpressEngineJs._(JSObject _) {
  external factory ZegoExpressEngineJs(JSNumber appId, JSString server);
  external JSPromise loginRoom(JSString roomId, JSString token, ZegoUserJs user);
  external JSPromise createStream(JSObject? config);
  // ... 50+ methods mapped
}
```

Key points:
- Every JS method is declared with `external` — Dart calls it, JS executes it
- Primitive types are auto-converted (`JSString` ↔ `String`, `JSNumber` ↔ `num`)
- Complex types (objects, arrays) need manual conversion

### `promise_adapter.dart` — Promises to Futures

Every async JS SDK method returns a `JSPromise`. The adapter converts these to Dart `Future`s with typed error handling:

```dart
Future<T> futureFromJsPromise<T>(
  JSPromise promise, {
  T Function(JSAny?)? converter,
})
```

How it works:
1. Awaits the JS Promise
2. Runs the optional converter on the resolved value
3. On rejection, maps the JS error to a `ZegoError`:
   - If error has `.code` and `.message` → `ZegoError(code, message)`
   - Otherwise → `ZegoError(-1, error.toString())`

This means every `ZegoEngine` method gives you a standard Dart `Future<T>` that throws a `ZegoError` on failure.

### `event_bridge.dart` — JS callbacks to Dart Streams

The JS SDK uses a callback pattern: `engine.on('eventName', callback)`. The event bridge converts these to Dart broadcast `Stream`s:

```dart
Stream<T> registerEvent<T>(
  String name,
  T Function(JSAny?, JSAny?, JSAny?, JSAny?) parse,
)
```

How it works:
1. On first `listen()`, installs a single JS callback via `engine.on(name, ...)`
2. The callback invokes the `parse` function to convert JS args to a typed Dart object
3. Emits the parsed object on a broadcast `StreamController`
4. Supports unlimited Dart subscribers per event
5. On `dispose()`, calls `engine.off(name, ...)` and closes all streams

### `sdk_loader.dart` — Script injection

Dynamically injects a `<script>` tag if the JS SDK isn't already loaded:

```dart
await ZegoWeb.loadScript(version: '3.6.0');
```

- Checks if `window.ZegoExpressEngine` already exists (manual `<script>` tag)
- If not, creates a `<script>` element pointing to unpkg CDN
- Waits for the `load` event before resolving
- Idempotent — calling multiple times is safe

### `token_bridge.dart` — Token refresh

Bridges the JS SDK's `tokenWillExpire` event to the `tokenProvider` callback you supply in `ZegoEngineConfig`:

1. On `loginRoom()`, calls `tokenProvider()` to get the initial token
2. When the SDK fires `tokenWillExpire`, calls `tokenProvider()` again
3. Passes the fresh token to the JS SDK via `renewToken()`

You write the fetch logic once; the bridge handles the refresh lifecycle.
