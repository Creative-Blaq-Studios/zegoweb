// packages/zegoweb/test/zego_web_test.dart
@TestOn('chrome')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter_test/flutter_test.dart';
import 'package:web/web.dart' as web;
import 'package:zegoweb/zegoweb.dart';

import 'fixtures/fake_zego_js.dart';

void _uninstall() {
  (web.window as JSObject)['ZegoExpressEngine'] = null;
}

void main() {
  group('ZegoWeb.createEngine', () {
    setUp(_uninstall);
    tearDown(_uninstall);

    test('throws when SDK not loaded and loadScript never called', () async {
      await expectLater(
        ZegoWeb.createEngine(
          ZegoEngineConfig(
            appId: 1,
            server: 'wss://example.com',
            scenario: ZegoScenario.general,
            tokenProvider: () async => '',
          ),
        ),
        throwsA(isA<ZegoStateError>()),
      );
    }, timeout: const Timeout(Duration(minutes: 1)));

    test('succeeds when fake SDK installed as window global', () async {
      final fake = FakeZegoJs()..installAsWindowGlobal();
      addTearDown(fake.uninstall);

      final engine = await ZegoWeb.createEngine(
        ZegoEngineConfig(
          appId: 1,
          server: 'wss://example.com',
          scenario: ZegoScenario.general,
          tokenProvider: () async => '',
        ),
      );
      expect(engine, isA<ZegoEngine>());
      await engine.destroy();
    });
  });
}
