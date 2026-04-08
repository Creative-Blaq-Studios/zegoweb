// packages/zegoweb/lib/src/interop/promise_adapter.dart
//
// Adapter from JS `Promise<T>` to Dart `Future<T>` with typed error mapping.
// Every call through the interop layer to a SDK method that returns a promise
// MUST go through this adapter so that JS rejections become `ZegoError`s.

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import '../models/zego_error.dart';

/// Converts a [JSPromise] into a Dart [Future].
///
/// If [convert] is provided, the resolved JS value is first converted to [T].
/// Otherwise the raw `JSAny?` is cast to [T]; callers that need type safety
/// must supply a converter.
///
/// Rejections are normalized:
///   * If the rejected value has `.code` (number) and `.message` (string),
///     throws `ZegoError(code, message)`.
///   * Otherwise throws `ZegoError(-1, <stringified value>)`.
///
/// Callers that want to promote `ZegoError` into a typed subclass
/// (`ZegoAuthException`, `ZegoNetworkException`, …) should catch here and
/// remap by code, since the adapter only knows the base type.
Future<T> futureFromJsPromise<T>(
  JSPromise<JSAny?> promise, {
  T Function(JSAny?)? convert,
}) async {
  try {
    final raw = await promise.toDart;
    if (convert != null) return convert(raw);
    return raw as T;
  } catch (e) {
    throw _mapJsError(e);
  }
}

ZegoError _mapJsError(Object error) {
  if (error is ZegoError) return error;

  // dart:js_interop surfaces JS rejections as JSObject (for object-shaped
  // errors) or as wrapped primitives. Try to read `code` / `message`.
  if (error is JSObject) {
    final codeAny = error['code'];
    final msgAny = error['message'];
    final code = _asInt(codeAny);
    final msg = _asString(msgAny);
    if (code != null && msg != null) {
      return ZegoError(code, msg, cause: error);
    }
    if (msg != null) {
      return ZegoError(-1, msg, cause: error);
    }
    // Unknown-shape JS error object — fall through to toString.
  }

  final text = error.toString();
  if (text.isEmpty || text == 'null') {
    return ZegoError(-1, 'unknown JS error', cause: error);
  }
  return ZegoError(-1, text, cause: error);
}

int? _asInt(JSAny? v) {
  if (v == null) return null;
  if (v.isA<JSNumber>()) return (v as JSNumber).toDartInt;
  return null;
}

String? _asString(JSAny? v) {
  if (v == null) return null;
  if (v.isA<JSString>()) return (v as JSString).toDart;
  return null;
}
