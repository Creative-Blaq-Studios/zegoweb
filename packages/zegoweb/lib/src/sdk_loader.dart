// packages/zegoweb/lib/src/sdk_loader.dart
//
// Hybrid SDK loader — §10 of the design spec.
//
// Two paths to readiness:
//   A. User adds a <script> tag to web/index.html. `SdkLoader.ready` detects
//      `window.ZegoExpressEngine` and resolves immediately.
//   B. User calls `SdkLoader.loadScript(version: ...)`. We inject a <script>
//      and resolve on its `load` event.
//
// If neither happens, `ready` times out (30s default) with a ZegoStateError
// that tells the developer exactly how to fix it.

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

import 'models/zego_error.dart';

/// Static loader for the `zego-express-engine-webrtc` JS SDK.
///
/// All state is static because there is exactly one SDK global per page.
abstract final class SdkLoader {
  static const Duration defaultTimeout = Duration(seconds: 30);
  // unpkg redirects `/zego-express-engine-webrtc@<version>` (no path) to the
  // package's main entry file, which is `ZegoExpressWebRTC.js`. Hard-coding
  // `/index.js` would 404. Dropping the path suffix makes us robust to
  // future ZEGO-side renames of the main file.
  static const String _cdnTemplate =
      'https://unpkg.com/zego-express-engine-webrtc@%VERSION%';

  static Completer<void>? _completer;
  static Future<void>? _loadScriptFuture;
  static web.HTMLScriptElement? _injectedTag;

  /// Resolves as soon as `window.ZegoExpressEngine` is present. If neither
  /// a manual <script> tag nor a `loadScript()` call has provided the SDK,
  /// this waits up to [defaultTimeout] and then rejects with `ZegoStateError`.
  static Future<void> get ready => readyWithTimeout(defaultTimeout);

  /// Same as [ready] with a caller-supplied timeout — used by tests.
  static Future<void> readyWithTimeout(Duration timeout) {
    // Fast path: already there.
    if (_hasGlobal()) return Future<void>.value();

    // If a loadScript() is in flight, piggy-back on its completer.
    if (_completer != null) {
      return _completer!.future.timeout(
        timeout,
        onTimeout: _throwNotLoaded,
      );
    }

    // Otherwise poll briefly so a manual <script> that races script parsing
    // still wins, then timeout.
    final c = Completer<void>();
    Timer? poll;
    Timer? deadline;

    void finishOk() {
      if (c.isCompleted) return;
      poll?.cancel();
      deadline?.cancel();
      c.complete();
    }

    void finishErr() {
      if (c.isCompleted) return;
      poll?.cancel();
      deadline?.cancel();
      c.completeError(
        const ZegoStateError(
          -1,
          'SDK not loaded — call ZegoWeb.loadScript() or add '
          '<script src="https://unpkg.com/zego-express-engine-webrtc/index.js"> '
          'to web/index.html',
        ),
      );
    }

    poll = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (_hasGlobal()) finishOk();
    });
    deadline = Timer(timeout, finishErr);

    return c.future;
  }

  /// Inject the SDK via a dynamic <script> tag. Idempotent: subsequent calls
  /// return the exact same Future.
  static Future<void> loadScript({String? version}) {
    // Fast-path: already loaded.
    if (_hasGlobal()) {
      _loadScriptFuture ??= Future<void>.value();
      return _loadScriptFuture!;
    }

    final existing = _loadScriptFuture;
    if (existing != null) return existing;

    final completer = Completer<void>();
    _completer = completer;
    _loadScriptFuture = completer.future;

    final src = _cdnTemplate.replaceFirst('%VERSION%', version ?? 'latest');
    final tag = web.HTMLScriptElement()
      ..src = src
      ..async = true
      ..defer = false;
    _injectedTag = tag;

    tag.addEventListener(
      'load',
      ((web.Event _) {
        if (_hasGlobal()) {
          if (!completer.isCompleted) completer.complete();
        } else {
          if (!completer.isCompleted) {
            completer.completeError(
              const ZegoStateError(
                -1,
                'SDK script loaded but window.ZegoExpressEngine is undefined '
                '(wrong URL or blocked by CSP?)',
              ),
            );
          }
        }
      }).toJS,
    );

    tag.addEventListener(
      'error',
      ((web.Event _) {
        if (!completer.isCompleted) {
          completer.completeError(
            ZegoStateError(
              -1,
              'Failed to load ZEGO SDK script from $src',
            ),
          );
        }
      }).toJS,
    );

    web.document.head?.appendChild(tag);
    return completer.future;
  }

  static bool _hasGlobal() {
    return (web.window as JSObject)['ZegoExpressEngine'] != null;
  }

  static Never _throwNotLoaded() {
    throw const ZegoStateError(
      -1,
      'SDK not loaded — call ZegoWeb.loadScript() or add '
      '<script src="https://unpkg.com/zego-express-engine-webrtc/index.js"> '
      'to web/index.html',
    );
  }

  /// Test-only: reset the loader so each test starts from a clean slate.
  /// Does NOT remove DOM script tags; callers should do that themselves.
  static void debugReset() {
    _completer = null;
    _loadScriptFuture = null;
    _injectedTag?.remove();
    _injectedTag = null;
  }
}
