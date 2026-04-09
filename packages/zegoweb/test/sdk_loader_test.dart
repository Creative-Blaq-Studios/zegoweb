// packages/zegoweb/test/sdk_loader_test.dart
@TestOn('chrome')
library;

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter_test/flutter_test.dart';
import 'package:web/web.dart' as web;
import 'package:zegoweb/src/models/zego_error.dart';
import 'package:zegoweb/src/sdk_loader.dart';

void _setGlobal(String key, JSAny? value) {
  (web.window as JSObject)[key] = value;
}

/// Find the inline `<script type="module">` tag SdkLoader injected.
/// It has no `src` attribute; we identify it by searching the inline text
/// for the ESM CDN hostname.
web.HTMLScriptElement? _findInjectedModule() {
  final scripts = web.document.querySelectorAll('script');
  for (var i = 0; i < scripts.length; i++) {
    final el = scripts.item(i);
    if (el is web.HTMLScriptElement &&
        el.type == 'module' &&
        el.text.contains('zego-express-engine-webrtc')) {
      return el;
    }
  }
  return null;
}

/// Remove every injected <script type="module"> that we recognise, plus any
/// existing ZegoExpressEngine global, so each test starts fresh.
void _cleanSlate() {
  _setGlobal('ZegoExpressEngine', null);
  final scripts = web.document.querySelectorAll('script');
  for (var i = 0; i < scripts.length; i++) {
    final el = scripts.item(i);
    if (el is web.HTMLScriptElement &&
        el.type == 'module' &&
        el.text.contains('zego-express-engine-webrtc')) {
      el.remove();
    }
  }
  SdkLoader.debugReset();
}

/// Fire the custom `zegoweb-sdk-ready` event that SdkLoader listens for.
/// Used by tests that want to simulate a successful module execution without
/// actually hitting the network.
void _dispatchReadyEvent() {
  web.window.dispatchEvent(web.Event('zegoweb-sdk-ready'));
}

void main() {
  group('SdkLoader', () {
    setUp(_cleanSlate);
    tearDown(_cleanSlate);

    test('ready resolves immediately when ZegoExpressEngine is already global',
        () async {
      _setGlobal('ZegoExpressEngine', JSObject());
      await SdkLoader.ready.timeout(const Duration(seconds: 1));
    });

    test('loadScript injects an inline module script with the version',
        () async {
      // Fire-and-forget: the test never lets the real network module execute;
      // it installs the global and fires the custom ready event instead.
      unawaited(SdkLoader.loadScript(version: '3.6.0'));

      final injected = _findInjectedModule();
      expect(injected, isNotNull, reason: 'module script was not injected');
      expect(injected!.type, 'module');
      // The inline text should contain the esm.sh import URL pinned to the
      // requested version.
      expect(injected.text, contains('esm.sh'));
      expect(injected.text, contains('zego-express-engine-webrtc@3.6.0'));
      expect(injected.text, contains("window.ZegoExpressEngine"));

      // Simulate the module body finishing execution.
      _setGlobal('ZegoExpressEngine', JSObject());
      _dispatchReadyEvent();

      await SdkLoader.ready.timeout(const Duration(seconds: 1));
    });

    test('loadScript is idempotent — second call returns the same future',
        () async {
      final f1 = SdkLoader.loadScript(version: '3.6.0');
      final f2 = SdkLoader.loadScript(version: '3.6.0');
      expect(identical(f1, f2), isTrue);

      // Only one module script should have been injected.
      var count = 0;
      final scripts = web.document.querySelectorAll('script');
      for (var i = 0; i < scripts.length; i++) {
        final el = scripts.item(i);
        if (el is web.HTMLScriptElement &&
            el.type == 'module' &&
            el.text.contains('zego-express-engine-webrtc')) {
          count++;
        }
      }
      expect(count, 1);
    });

    test('ready times out with ZegoStateError when SDK never loads', () async {
      await expectLater(
        SdkLoader.readyWithTimeout(const Duration(milliseconds: 50)),
        throwsA(
          isA<ZegoStateError>().having(
            (e) => e.message,
            'message',
            contains('SDK not loaded'),
          ),
        ),
      );
    });

    test('loadScript onerror rejects with ZegoStateError', () async {
      final f = SdkLoader.loadScript(version: '3.6.0');
      final injected = _findInjectedModule();
      expect(injected, isNotNull);
      injected!.dispatchEvent(web.Event('error'));

      await expectLater(
        f,
        throwsA(isA<ZegoStateError>()),
      );
    });
  });
}
