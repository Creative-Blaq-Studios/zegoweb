// packages/zegoweb/lib/src/models/zego_error.dart
import 'package:meta/meta.dart';

import 'zego_enums.dart';

/// Base exception for every error surfaced by `zegoweb`.
///
/// `code` matches the underlying JS SDK error code when possible, or a
/// plugin-specific code (negative values) for errors that originate inside
/// the Dart layer. `cause` holds the original JS error object or whatever
/// triggered the wrap, for debugging. `stackTrace` holds the Dart stack
/// trace captured when the error was raised.
@immutable
class ZegoError implements Exception {
  const ZegoError(
    this.code,
    this.message, {
    this.cause,
    this.stackTrace,
  });

  final int code;
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() {
    final buf = StringBuffer('$runtimeType($code, $message');
    if (cause != null) buf.write(', cause: $cause');
    buf.write(')');
    return buf.toString();
  }
}

/// Raised when camera/microphone access fails. `kind` distinguishes
/// user-denial from missing hardware from a device in use by another app
/// from a non-secure context.
class ZegoPermissionException extends ZegoError {
  const ZegoPermissionException(
    super.code,
    super.message, {
    required this.kind,
    super.cause,
    super.stackTrace,
  });

  final PermissionErrorKind kind;

  @override
  String toString() {
    final buf =
        StringBuffer('$runtimeType($code, $message, kind: ${kind.name}');
    if (cause != null) buf.write(', cause: $cause');
    buf.write(')');
    return buf.toString();
  }
}

/// Raised for network/server-side failures reported by the JS SDK.
class ZegoNetworkException extends ZegoError {
  const ZegoNetworkException(
    super.code,
    super.message, {
    super.cause,
    super.stackTrace,
  });
}

/// Raised for token / authentication failures.
class ZegoAuthException extends ZegoError {
  const ZegoAuthException(
    super.code,
    super.message, {
    super.cause,
    super.stackTrace,
  });
}

/// Raised for device enumeration / acquisition failures not covered by
/// `ZegoPermissionException` (e.g. unplugged mid-call, transient hardware
/// error).
class ZegoDeviceException extends ZegoError {
  const ZegoDeviceException(
    super.code,
    super.message, {
    super.cause,
    super.stackTrace,
  });
}

/// Raised when the caller misuses the engine: calling methods after
/// `destroy()`, or out of the documented lifecycle order
/// (e.g. `startPublishing` before `loginRoom`).
class ZegoStateError extends ZegoError {
  const ZegoStateError(
    super.code,
    super.message, {
    super.cause,
    super.stackTrace,
  });
}
