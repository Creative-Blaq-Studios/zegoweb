// packages/zegoweb/test/zego_engine_local_stream_test.dart
@TestOn('chrome')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb/src/models/zego_config.dart';
import 'package:zegoweb/src/models/zego_enums.dart';
import 'package:zegoweb/src/models/zego_error.dart';
import 'package:zegoweb/src/zego_engine.dart';

import 'fixtures/fake_zego_js.dart';

void main() {
  group('ZegoEngine.createLocalStream', () {
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

    test('returns a ZegoLocalStream with the fake stream id', () async {
      fake.nextCreatedStreamId = 'local-xyz';
      final stream = await engine.createLocalStream(
        config: const ZegoStreamConfig(camera: true, microphone: true),
      );
      expect(stream.id, 'local-xyz');
      expect(engine.debugLocals.values, contains(stream));
    });

    test('NotAllowedError from getUserMedia → ZegoPermissionException denied',
        () async {
      fake.rejectNextCreateStream(jsName: 'NotAllowedError', message: 'denied');
      try {
        await engine.createLocalStream();
        fail('expected ZegoPermissionException');
      } on ZegoPermissionException catch (e) {
        expect(e.kind, PermissionErrorKind.denied);
      }
    });

    test('NotFoundError → ZegoPermissionException notFound', () async {
      fake.rejectNextCreateStream(jsName: 'NotFoundError', message: 'none');
      try {
        await engine.createLocalStream();
        fail('expected ZegoPermissionException');
      } on ZegoPermissionException catch (e) {
        expect(e.kind, PermissionErrorKind.notFound);
      }
    });

    test('NotReadableError → ZegoPermissionException inUse', () async {
      fake.rejectNextCreateStream(jsName: 'NotReadableError', message: 'busy');
      try {
        await engine.createLocalStream();
        fail('expected ZegoPermissionException');
      } on ZegoPermissionException catch (e) {
        expect(e.kind, PermissionErrorKind.inUse);
      }
    });
  });
}
