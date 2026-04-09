// packages/zegoweb/test/zego_engine_room_test.dart
@TestOn('chrome')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb/src/models/zego_enums.dart';
import 'package:zegoweb/src/models/zego_error.dart';
import 'package:zegoweb/src/models/zego_user.dart';
import 'package:zegoweb/src/zego_engine.dart';

import 'fixtures/fake_zego_js.dart';

void main() {
  group('ZegoEngine room lifecycle', () {
    late FakeZegoJs fake;
    late ZegoEngine engine;

    setUp(() {
      fake = FakeZegoJs();
      engine = ZegoEngine.test(
        js: fake.asJs(),
        tokenProvider: () async => 'test-token',
      );
    });

    tearDown(() async {
      await engine.destroy();
    });

    test('loginRoom calls JS loginRoom with token + user', () async {
      await engine.loginRoom(
        'room-1',
        const ZegoUser(userId: 'u1', userName: 'Alice'),
      );
      expect(fake.loginCalls, hasLength(1));
      final call = fake.loginCalls.single;
      expect(call.roomId, 'room-1');
      expect(call.token, 'test-token');
      expect(call.userId, 'u1');
      expect(call.userName, 'Alice');
    });

    test('loginRoom forwards room state transitions to onRoomStateChanged',
        () async {
      final states = <ZegoRoomState>[];
      final sub = engine.onRoomStateChanged.listen(states.add);
      await engine.loginRoom(
        'room-1',
        const ZegoUser(userId: 'u1', userName: 'A'),
      );
      fake.emitRoomStateUpdate('room-1', 'CONNECTING');
      fake.emitRoomStateUpdate('room-1', 'CONNECTED');
      await Future<void>.delayed(Duration.zero);
      expect(
          states,
          containsAllInOrder(<ZegoRoomState>[
            ZegoRoomState.connecting,
            ZegoRoomState.connected,
          ]));
      await sub.cancel();
    });

    test('room state DISCONNECTED failure is surfaced on onError', () async {
      final errors = <ZegoError>[];
      final sub = engine.onError.listen(errors.add);
      await engine.loginRoom(
        'room-1',
        const ZegoUser(userId: 'u1', userName: 'A'),
      );
      fake.emitRoomStateUpdate('room-1', 'DISCONNECTED',
          errorCode: 1002033, extendedData: 'kicked out');
      await Future<void>.delayed(Duration.zero);
      expect(errors, isNotEmpty);
      await sub.cancel();
    });

    test('logoutRoom clears current room and calls JS logoutRoom', () async {
      await engine.loginRoom(
        'room-1',
        const ZegoUser(userId: 'u1', userName: 'A'),
      );
      await engine.logoutRoom();
      expect(fake.logoutCalls, contains('room-1'));
    });

    test('logoutRoom without an active room is a no-op', () async {
      await engine.logoutRoom();
      expect(fake.logoutCalls, isEmpty);
    });

    test('loginRoom propagates JS rejection as ZegoError', () async {
      fake.rejectNextLogin(code: 1002030, message: 'auth failure');
      await expectLater(
        engine.loginRoom(
          'room-1',
          const ZegoUser(userId: 'u1', userName: 'A'),
        ),
        throwsA(isA<ZegoError>()),
      );
    });
  });
}
