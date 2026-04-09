// packages/zegoweb/test/interop/log_bridge_test.dart
@TestOn('chrome')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb/src/interop/log_bridge.dart';
import 'package:zegoweb/src/models/zego_enums.dart';

import '../fixtures/fake_zego_js.dart';

void main() {
  group('configureJsLogging', () {
    late FakeZegoJs fake;
    late JSObject engine;

    setUp(() {
      fake = FakeZegoJs();
      engine = fake.asJs();
    });

    test('maps ZegoLogLevel.verbose → "debug" and disables remote logging', () {
      configureJsLogging(engine, ZegoLogLevel.verbose);
      final call = fake.callArgs['setLogConfig']!.single;
      final cfg = call.single as JSObject;
      expect(((cfg['logLevel'] as JSString).toDart), 'debug');
      expect(((cfg['remoteLogLevel'] as JSString).toDart), 'disable');
    });

    test('maps ZegoLogLevel.info → "info"', () {
      configureJsLogging(engine, ZegoLogLevel.info);
      final cfg = fake.callArgs['setLogConfig']!.single.single as JSObject;
      expect(((cfg['logLevel'] as JSString).toDart), 'info');
    });

    test('maps ZegoLogLevel.warn → "warn"', () {
      configureJsLogging(engine, ZegoLogLevel.warn);
      final cfg = fake.callArgs['setLogConfig']!.single.single as JSObject;
      expect(((cfg['logLevel'] as JSString).toDart), 'warn');
    });

    test('maps ZegoLogLevel.error → "error"', () {
      configureJsLogging(engine, ZegoLogLevel.error);
      final cfg = fake.callArgs['setLogConfig']!.single.single as JSObject;
      expect(((cfg['logLevel'] as JSString).toDart), 'error');
    });

    test('maps ZegoLogLevel.off → "disable"', () {
      configureJsLogging(engine, ZegoLogLevel.off);
      final cfg = fake.callArgs['setLogConfig']!.single.single as JSObject;
      expect(((cfg['logLevel'] as JSString).toDart), 'disable');
    });
  });
}
