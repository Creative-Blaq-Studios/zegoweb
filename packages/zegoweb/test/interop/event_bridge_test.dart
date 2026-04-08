// packages/zegoweb/test/interop/event_bridge_test.dart
@TestOn('chrome')
library;

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb/src/interop/event_bridge.dart';

import '../fixtures/fake_zego_js.dart';

void main() {
  group('EventBridge', () {
    late FakeZegoJs fake;
    late JSObject engine;
    late EventBridge bridge;

    setUp(() {
      fake = FakeZegoJs();
      engine = fake.asJs();
      bridge = EventBridge(engine);
    });

    tearDown(() async {
      await bridge.dispose();
    });

    test('registerEvent returns a broadcast stream and delivers events',
        () async {
      final stream = bridge.registerEvent<String>(
        'roomStateUpdate',
        (raw) => ((raw as JSObject)['state'] as JSString).toDart,
      );
      expect(stream.isBroadcast, isTrue);

      final received = <String>[];
      final sub = stream.listen(received.add);

      fake.driveEvent(
        'roomStateUpdate',
        <String, Object?>{'state': 'CONNECTED'}.jsify(),
      );
      fake.driveEvent(
        'roomStateUpdate',
        <String, Object?>{'state': 'DISCONNECTED'}.jsify(),
      );

      await Future<void>.delayed(Duration.zero);
      expect(received, <String>['CONNECTED', 'DISCONNECTED']);

      await sub.cancel();
    });

    test(
        'registerEvent called twice for the same name returns the SAME stream '
        'and registers exactly one JS listener', () async {
      final a = bridge.registerEvent<JSAny?>('roomUserUpdate', (r) => r);
      final b = bridge.registerEvent<JSAny?>('roomUserUpdate', (r) => r);
      expect(identical(a, b), isTrue);
      expect(fake.listenerCount('roomUserUpdate'), 1);
    });

    test('dispose removes JS listeners and closes controllers', () async {
      final stream =
          bridge.registerEvent<JSAny?>('roomStreamUpdate', (r) => r);
      final received = <Object?>[];
      final sub =
          stream.listen(received.add, onDone: () => received.add('#done'));

      fake.driveEvent('roomStreamUpdate', 'first'.toJS);
      await Future<void>.delayed(Duration.zero);
      expect(received, <Object?>['first']);

      await bridge.dispose();
      expect(fake.listenerCount('roomStreamUpdate'), 0);

      fake.driveEvent('roomStreamUpdate', 'late'.toJS);
      await Future<void>.delayed(Duration.zero);
      expect(received, <Object?>['first', '#done']);

      await sub.cancel();
    });

    test('dispose is idempotent', () async {
      bridge.registerEvent<JSAny?>('publisherStateUpdate', (r) => r);
      await bridge.dispose();
      await bridge.dispose(); // must not throw
    });

    test('typed onRoomStateUpdate parses state + errorCode', () async {
      final received = <String>[];
      final errorCodes = <int?>[];
      final sub = bridge.onRoomStateUpdate.listen((e) {
        received.add(e.state.name);
        errorCodes.add(e.errorCode);
      });

      fake.emitRoomStateUpdate('room-1', 'CONNECTED');
      fake.emitRoomStateUpdate(
        'room-1',
        'DISCONNECTED',
        errorCode: 1002033,
        extendedData: 'kicked',
      );
      await Future<void>.delayed(Duration.zero);

      expect(received, <String>['connected', 'disconnected']);
      expect(errorCodes, <int?>[null, 1002033]);
      await sub.cancel();
    });
  });
}
