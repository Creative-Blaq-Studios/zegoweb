// packages/zegoweb/test/zego_engine_publish_test.dart
@TestOn('chrome')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb/src/models/zego_error.dart';
import 'package:zegoweb/src/models/zego_user.dart';
import 'package:zegoweb/src/zego_engine.dart';

import 'fixtures/fake_zego_js.dart';

void main() {
  group('ZegoEngine publishing', () {
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

    test('startPublishing without loginRoom throws ZegoStateError', () async {
      fake.nextCreatedStreamId = 'l1';
      final local = await engine.createLocalStream();
      await expectLater(
        engine.startPublishing('l1', local),
        throwsA(isA<ZegoStateError>()),
      );
    });

    test('startPublishing calls JS startPublishingStream(id, stream)',
        () async {
      await engine.loginRoom('r1', const ZegoUser(userId: 'u', userName: 'U'));
      fake.nextCreatedStreamId = 'l1';
      final local = await engine.createLocalStream();
      await engine.startPublishing('l1', local);
      expect(fake.publishCalls, hasLength(1));
      expect(fake.publishCalls.single.streamId, 'l1');
    });

    test('stopPublishing calls JS stopPublishingStream', () async {
      await engine.loginRoom('r1', const ZegoUser(userId: 'u', userName: 'U'));
      fake.nextCreatedStreamId = 'l1';
      final local = await engine.createLocalStream();
      await engine.startPublishing('l1', local);
      await engine.stopPublishing('l1');
      expect(fake.stopPublishCalls, contains('l1'));
    });

    test('publisherStateUpdate PUBLISH_FAILED flows to onError', () async {
      final errors = <ZegoError>[];
      final sub = engine.onError.listen(errors.add);
      await engine.loginRoom('r1', const ZegoUser(userId: 'u', userName: 'U'));
      fake.emitPublisherStateUpdate(
          'l1', 'PUBLISH_FAILED', 1003024, 'stream not exist');
      await Future<void>.delayed(Duration.zero);
      expect(errors, hasLength(1));
      expect(errors.single.code, 1003024);
      await sub.cancel();
    });
  });
}
