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
  // The zego-express-engine-webrtc package does not ship a browser-ready
  // UMD bundle — its main file (ZegoExpressWebRTC.js) is a UMD wrapper that
  // tries to `require()` four CJS dependencies (long, protobufjs, localforage,
  // zego-express-logger) and falls back to reading them from globals in the
  // browser path, which will never exist. The intended consumption model is
  // npm + a bundler (webpack/vite/rollup).
  //
  // For script-tag loading we route through esm.sh, which does on-the-fly
  // bundling of npm packages into ES modules with transitive deps inlined.
  // We inject a `<script type="module">` that imports the default export and
  // assigns it to `window.ZegoExpressEngine` so the rest of the plugin can
  // find it via the existing @JS('ZegoExpressEngine') extern.
  static const String _esmTemplate =
      'https://esm.sh/zego-express-engine-webrtc@%VERSION%';

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

  /// Inject the SDK via a dynamic <script type="module"> tag. Idempotent:
  /// subsequent calls return the exact same Future.
  ///
  /// The script is inline (no `src` attribute) and does:
  /// ```js
  /// import ZegoExpressEngine from 'https://esm.sh/zego-express-engine-webrtc@<version>';
  /// window.ZegoExpressEngine = ZegoExpressEngine;
  /// window.__zegowebSdkReady = true;
  /// ```
  /// We poll `window.ZegoExpressEngine` to decide when the module finished
  /// executing — ES-module scripts don't fire a `load` event on the tag that
  /// reliably signals "import completed", so a short poll is simplest.
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

    final esmUrl = _esmTemplate.replaceFirst('%VERSION%', version ?? 'latest');
    // The esm.sh default export for zego-express-engine-webrtc is a
    // namespace object, not the class constructor itself. The real
    // constructor lives at `.ZegoExpressEngine` on that namespace. We
    // walk three possible paths (ns.ZegoExpressEngine → ns.default →
    // ns itself) and verify typeof before assigning to
    // `window.ZegoExpressEngine`, which is where the Dart-side
    // @JS('ZegoExpressEngine') extern looks for it. Any import failure
    // is surfaced via `window.__zegowebLoadError` and caught by the
    // ready-event handler below, so developers get a descriptive error
    // instead of a downstream constructor crash.
    final tag = web.HTMLScriptElement()
      ..type = 'module'
      ..text = '''
try {
  const mod = await import('$esmUrl');
  const ns = mod.default ?? mod;
  let ctor = ns.ZegoExpressEngine ?? ns.default ?? ns;
  if (typeof ctor !== 'function' && ctor && typeof ctor === 'object') {
    if (typeof ctor.ZegoExpressEngine === 'function') {
      ctor = ctor.ZegoExpressEngine;
    } else if (typeof ctor.default === 'function') {
      ctor = ctor.default;
    }
  }
  if (typeof ctor !== 'function') {
    throw new Error('esm.sh returned '
      + (typeof ctor) + ', expected a constructor function. '
      + 'Top keys: ' + Object.keys(ns).slice(0, 30).join(', '));
  }
  window.ZegoExpressEngine = ctor;
  window.dispatchEvent(new Event('zegoweb-sdk-ready'));
} catch (err) {
  window.__zegowebLoadError = String(err && err.message ? err.message : err);
  window.dispatchEvent(new Event('zegoweb-sdk-ready'));
}
'''
      ..async = true
      ..defer = false;
    _injectedTag = tag;

    // An ES-module <script> fires its tag-level 'load' event when the module
    // text has been fetched, but NOT after the module body has finished
    // executing. We listen to our custom 'zegoweb-sdk-ready' event instead,
    // which is dispatched from inside the module body above — both on
    // success and on a caught import error.
    web.window.addEventListener(
      'zegoweb-sdk-ready',
      ((web.Event _) {
        if (completer.isCompleted) return;
        final winObj = web.window as JSObject;
        final loadErr = winObj['__zegowebLoadError'];
        if (loadErr != null) {
          final msg = loadErr is JSString
              ? loadErr.toDart
              : loadErr.toString();
          completer.completeError(
            ZegoStateError(
              -1,
              'Failed to import ZEGO SDK module: $msg',
            ),
          );
          return;
        }
        if (_hasGlobal()) {
          completer.complete();
        } else {
          completer.completeError(
            const ZegoStateError(
              -1,
              'SDK module executed but window.ZegoExpressEngine is undefined',
            ),
          );
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
              'Failed to load ZEGO SDK module from $esmUrl',
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
    (web.window as JSObject)['__zegowebLoadError'] = null;
  }
}
