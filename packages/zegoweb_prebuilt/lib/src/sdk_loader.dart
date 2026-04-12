// packages/zegoweb_prebuilt/lib/src/sdk_loader.dart
//
// SDK loader for the @zegocloud/zego-uikit-prebuilt UMD bundle.
//
// Plain <script src=...> injection from unpkg. Polls for
// window.ZegoUIKitPrebuilt after the load event, completes a Future<void>.
// Static singleton, idempotent.

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

import 'zego_prebuilt_error.dart';

/// Static loader for the `@zegocloud/zego-uikit-prebuilt` JS UIKit.
///
/// All state is static because there is exactly one UIKit global per page.
abstract final class SdkLoader {
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const String _cdnTemplate =
      'https://unpkg.com/@zegocloud/zego-uikit-prebuilt@%VERSION%/zego-uikit-prebuilt.js';

  static Completer<void>? _completer;
  static Future<void>? _loadScriptFuture;

  /// Resolves as soon as `window.ZegoUIKitPrebuilt` is present.
  static Future<void> get ready => readyWithTimeout(defaultTimeout);

  /// Same as [ready] with a caller-supplied timeout — used by tests.
  static Future<void> readyWithTimeout(Duration timeout) {
    if (_hasGlobal()) return Future<void>.value();

    if (_completer != null) {
      return _completer!.future.timeout(
        timeout,
        onTimeout: _throwNotLoaded,
      );
    }

    // Poll briefly so a manual <script> that races script parsing still wins.
    final c = Completer<void>();
    Timer? poll;
    poll = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (_hasGlobal()) {
        poll?.cancel();
        if (!c.isCompleted) c.complete();
      }
    });

    return c.future.timeout(timeout, onTimeout: () {
      poll?.cancel();
      _throwNotLoaded();
    });
  }

  /// Inject the prebuilt UIKit via a `<script>` tag. Idempotent.
  static Future<void> loadScript({String? version}) {
    if (_loadScriptFuture != null) return _loadScriptFuture!;

    if (_hasGlobal()) {
      _loadScriptFuture = Future<void>.value();
      return _loadScriptFuture!;
    }

    _completer = Completer<void>();
    final url = _cdnTemplate.replaceFirst(
      '%VERSION%',
      version ?? 'latest',
    );

    final script = web.document.createElement('script') as web.HTMLScriptElement
      ..src = url;

    script.addEventListener(
      'load',
      ((web.Event event) {
        if (_hasGlobal() && _completer != null && !_completer!.isCompleted) {
          _completer!.complete();
        }
      }).toJS,
    );

    script.addEventListener(
      'error',
      ((web.Event event) {
        if (_completer != null && !_completer!.isCompleted) {
          _completer!.completeError(
            ZegoStateError(
              -1,
              'Failed to load the prebuilt UIKit script from $url. '
              'Check the version and your network connection.',
            ),
          );
        }
      }).toJS,
    );

    web.document.head!.append(script);

    _loadScriptFuture = _completer!.future;
    return _loadScriptFuture!;
  }

  /// Test-only: reset all static state.
  static void debugReset() {
    _completer = null;
    _loadScriptFuture = null;
  }

  static bool _hasGlobal() {
    return (web.window as JSObject)['ZegoUIKitPrebuilt'] != null;
  }

  static Never _throwNotLoaded() {
    throw ZegoStateError(
      -1,
      'SDK not loaded: window.ZegoUIKitPrebuilt is not defined. '
      'Call SdkLoader.loadScript() or add a '
      '<script src="https://unpkg.com/@zegocloud/zego-uikit-prebuilt/zego-uikit-prebuilt.js"></script> '
      'tag to web/index.html.',
    );
  }
}
