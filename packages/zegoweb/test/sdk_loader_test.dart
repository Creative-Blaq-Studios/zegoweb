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

/// Remove every <script src="*zego-express-engine-webrtc*"> tag and any
/// existing ZegoExpressEngine global, so each test starts fresh.
void _cleanSlate() {
  _setGlobal('ZegoExpressEngine', null);
  final scripts = web.document.querySelectorAll('script');
  for (var i = 0; i < scripts.length; i++) {
    final el = scripts.item(i);
    if (el is web.HTMLScriptElement &&
        el.src.contains('zego-express-engine-webrtc')) {
      el.remove();
    }
  }
  SdkLoader.debugReset();
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

    test('loadScript injects a script tag with the requested version',
        () async {
      // Fire-and-forget: we don't let the real network load; we install the
      // global before the timeout fires, simulating onload.
      unawaited(SdkLoader.loadScript(version: '3.6.0'));

      // Find the injected script element.
      final scripts = web.document.querySelectorAll('script');
      web.HTMLScriptElement? injected;
      for (var i = 0; i < scripts.length; i++) {
        final el = scripts.item(i);
        if (el is web.HTMLScriptElement &&
            el.src.contains('zego-express-engine-webrtc@3.6.0')) {
          injected = el;
          break;
        }
      }
      expect(injected, isNotNull, reason: 'script tag was not injected');
      expect(injected!.src, contains('unpkg.com'));
      expect(injected.src, contains('@3.6.0'));

      // Simulate the script finishing.
      _setGlobal('ZegoExpressEngine', JSObject());
      injected.dispatchEvent(web.Event('load'));

      await SdkLoader.ready.timeout(const Duration(seconds: 1));
    });

    test('loadScript is idempotent — second call returns the same future',
        () async {
      final f1 = SdkLoader.loadScript(version: '3.6.0');
      final f2 = SdkLoader.loadScript(version: '3.6.0');
      expect(identical(f1, f2), isTrue);

      // Only one script tag should have been injected.
      var count = 0;
      final scripts = web.document.querySelectorAll('script');
      for (var i = 0; i < scripts.length; i++) {
        final el = scripts.item(i);
        if (el is web.HTMLScriptElement &&
            el.src.contains('zego-express-engine-webrtc')) {
          count++;
        }
      }
      expect(count, 1);
    });

    test('ready times out with ZegoStateError when SDK never loads',
        () async {
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
      final scripts = web.document.querySelectorAll('script');
      web.HTMLScriptElement? injected;
      for (var i = 0; i < scripts.length; i++) {
        final el = scripts.item(i);
        if (el is web.HTMLScriptElement &&
            el.src.contains('zego-express-engine-webrtc')) {
          injected = el;
          break;
        }
      }
      expect(injected, isNotNull);
      injected!.dispatchEvent(web.Event('error'));

      await expectLater(
        f,
        throwsA(isA<ZegoStateError>()),
      );
    });
  });
}
