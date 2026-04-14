---
sidebar_position: 5
title: Error Handling
---

# Error Handling

`zegoweb` provides a typed error hierarchy so you can handle failures precisely.

## Error types

| Exception | When it's thrown |
|---|---|
| `ZegoError` | Base type. Any SDK error with a `code` and `message`. |
| `ZegoPermissionException` | Camera/mic permission denied, device not found, or device in use. |
| `ZegoNetworkException` | Network connectivity issues. |
| `ZegoAuthException` | Token invalid, expired, or rejected. |
| `ZegoDeviceException` | Device-level failures (hardware errors). |
| `ZegoStateError` | Invalid state (e.g., calling methods before login, insecure context). |

## Catching errors

### Synchronous errors (from method calls)

```dart
try {
  await engine.loginRoom('room-1', user);
} on ZegoAuthException catch (e) {
  print('Auth failed: ${e.message}');
} on ZegoNetworkException catch (e) {
  print('Network issue: ${e.message}');
} on ZegoError catch (e) {
  print('SDK error ${e.code}: ${e.message}');
}
```

### Async errors (from the error stream)

Some errors happen asynchronously (e.g., connection drops mid-call):

```dart
engine.onError.listen((error) {
  print('Async error: ${error.code} — ${error.message}');
});
```

### Permission errors

```dart
try {
  final stream = await engine.createLocalStream();
} on ZegoPermissionException catch (e) {
  switch (e.kind) {
    case PermissionErrorKind.denied:
      print('User denied camera/mic access');
    case PermissionErrorKind.notFound:
      print('No camera/mic found');
    case PermissionErrorKind.inUse:
      print('Device is in use by another app');
    case PermissionErrorKind.insecureContext:
      print('HTTPS required');
  }
}
```
