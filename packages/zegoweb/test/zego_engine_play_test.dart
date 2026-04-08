// packages/zegoweb/test/zego_engine_play_test.dart
@TestOn('chrome')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb/src/models/zego_enums.dart';
import 'package:zegoweb/src/models/zego_error.dart';
import 'package:zegoweb/src/models/zego_events.dart';
import 'package:zegoweb/src/models/zego_user.dart';
import 'package:zegoweb/src/zego_engine.dart';

import 'fixtures/fake_zego_js.dart';

void main() {
  group('ZegoEngine playback', () {
    late FakeZegoJs fake;
    late ZegoEngine engine;

    setUp(() {
      fake = FakeZegoJs();
      engine = ZegoEngine.test(
        js: fake.asJs(),
        tokenProvider: () async => 'tok',
      );
    });

    tearDown(() async {
      await engine.destroy();
    });

    test('startPlaying without loginRoom throws ZegoStateError', () async {
      await expectLater(
        engine.startPlaying('rx1'),
        throwsA(isA<ZegoStateError>()),
      );
    });

    test('startPlaying returns a ZegoRemoteStream with the stream id',
        () async {
      await engine.loginRoom('r1', const ZegoUser(userId: 'u', userName: 'U'));
      final remote = await engine.startPlaying('remote-1');
      expect(remote.id, 'remote-1');
      expect(engine.debugRemotes, contains('remote-1'));
    });

    test('stopPlaying removes the cached remote stream', () async {
      await engine.loginRoom('r1', const ZegoUser(userId: 'u', userName: 'U'));
      await engine.startPlaying('remote-1');
      await engine.stopPlaying('remote-1');
      expect(engine.debugRemotes, isNot(contains('remote-1')));
      expect(fake.stopPlayCalls, contains('remote-1'));
    });

    test('playerStateUpdate PLAY_FAILED flows to onError', () async {
      final errors = <ZegoError>[];
      final sub = engine.onError.listen(errors.add);
      await engine.loginRoom('r1', const ZegoUser(userId: 'u', userName: 'U'));
      fake.emitPlayerStateUpdate(
          'remote-1', 'PLAY_FAILED', 1004024, 'stream not exist');
      await Future<void>.delayed(Duration.zero);
      expect(errors, hasLength(1));
      expect(errors.single.code, 1004024);
      await sub.cancel();
    });

    test('roomStreamUpdate forwarded to onRoomStreamUpdate', () async {
      final updates = <ZegoRoomStreamUpdate>[];
      final sub = engine.onRoomStreamUpdate.listen(updates.add);
      await engine.loginRoom('r1', const ZegoUser(userId: 'u', userName: 'U'));
      fake.emitRoomStreamUpdate(
        'r1',
        ZegoUpdateType.add,
        const [('remote-1', 'u2', 'Bob')],
      );
      await Future<void>.delayed(Duration.zero);
      expect(updates, hasLength(1));
      expect(updates.single.streams.single.streamId, 'remote-1');
      await sub.cancel();
    });
  });
}
