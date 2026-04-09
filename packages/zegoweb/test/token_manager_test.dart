// packages/zegoweb/test/token_manager_test.dart
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb/src/models/zego_error.dart';
import 'package:zegoweb/src/models/zego_events.dart';
import 'package:zegoweb/src/token_bridge.dart';
import 'package:zegoweb/src/token_manager.dart';

class _FakeBridge implements TokenBridge {
  final StreamController<ZegoTokenWillExpire> _controller =
      StreamController<ZegoTokenWillExpire>.broadcast();

  @override
  Stream<ZegoTokenWillExpire> get onTokenWillExpire => _controller.stream;

  void fire(ZegoTokenWillExpire event) => _controller.add(event);

  Future<void> close() => _controller.close();
}

class _FakeClock implements TokenClock {
  DateTime _now = DateTime.utc(2026, 4, 8);
  @override
  DateTime now() => _now;
  void advance(Duration d) => _now = _now.add(d);
}

void main() {
  group('TokenManager.initialToken', () {
    test('delegates to the provider', () async {
      var calls = 0;
      final tm = TokenManager(
        tokenProvider: () async {
          calls++;
          return 'tok-1';
        },
        clock: _FakeClock(),
      );
      expect(await tm.initialToken(), 'tok-1');
      expect(calls, 1);
    });

    test('propagates provider exceptions as ZegoAuthException', () async {
      final tm = TokenManager(
        tokenProvider: () async => throw StateError('boom'),
        clock: _FakeClock(),
      );
      await expectLater(
        tm.initialToken(),
        throwsA(isA<ZegoAuthException>()),
      );
    });
  });

  group('TokenManager.wireRefresh', () {
    test('calls provider + renewFn when tokenWillExpire fires', () async {
      final bridge = _FakeBridge();
      final errorSink = StreamController<ZegoError>.broadcast();
      final renewed = <(String, String)>[];
      var providerCalls = 0;

      final tm = TokenManager(
        tokenProvider: () async {
          providerCalls++;
          return 'tok-refresh';
        },
        clock: _FakeClock(),
      );

      tm.wireRefresh(bridge, (roomId, token) async {
        renewed.add((roomId, token));
      }, errorSink);

      bridge.fire(
        const ZegoTokenWillExpire(roomId: 'room-1', remainingSeconds: 30),
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(providerCalls, 1);
      expect(renewed, [('room-1', 'tok-refresh')]);
      tm.dispose();
      await bridge.close();
      await errorSink.close();
    });

    test('emits ZegoAuthException on provider failure', () async {
      final bridge = _FakeBridge();
      final errorSink = StreamController<ZegoError>.broadcast();
      final events = <ZegoError>[];
      errorSink.stream.listen(events.add);

      final tm = TokenManager(
        tokenProvider: () async => throw Exception('no network'),
        clock: _FakeClock(),
      );
      tm.wireRefresh(bridge, (_, __) async {}, errorSink);

      bridge.fire(
        const ZegoTokenWillExpire(roomId: 'room-1', remainingSeconds: 30),
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.single, isA<ZegoAuthException>());
      tm.dispose();
      await bridge.close();
      await errorSink.close();
    });

    test('emits ZegoAuthException when renewFn fails', () async {
      final bridge = _FakeBridge();
      final errorSink = StreamController<ZegoError>.broadcast();
      final events = <ZegoError>[];
      errorSink.stream.listen(events.add);

      final tm = TokenManager(
        tokenProvider: () async => 'tok',
        clock: _FakeClock(),
      );
      tm.wireRefresh(
        bridge,
        (_, __) async => throw Exception('js fail'),
        errorSink,
      );

      bridge.fire(
        const ZegoTokenWillExpire(roomId: 'room-1', remainingSeconds: 30),
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.single, isA<ZegoAuthException>());
      tm.dispose();
      await bridge.close();
      await errorSink.close();
    });

    test('dispose cancels subscription; further events are ignored', () async {
      final bridge = _FakeBridge();
      final errorSink = StreamController<ZegoError>.broadcast();
      var calls = 0;

      final tm = TokenManager(
        tokenProvider: () async {
          calls++;
          return 'tok';
        },
        clock: _FakeClock(),
      );
      tm.wireRefresh(bridge, (_, __) async {}, errorSink);
      tm.dispose();
      bridge.fire(
        const ZegoTokenWillExpire(roomId: 'room-1', remainingSeconds: 30),
      );
      await Future<void>.delayed(Duration.zero);

      expect(calls, 0);
      await bridge.close();
      await errorSink.close();
    });

    test('dispose is idempotent', () {
      final tm = TokenManager(
        tokenProvider: () async => 'tok',
        clock: _FakeClock(),
      );
      tm.dispose();
      expect(tm.dispose, returnsNormally);
    });
  });
}
