// packages/zegoweb/test/zego_engine_devices_test.dart
@TestOn('chrome')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb/src/models/zego_enums.dart';
import 'package:zegoweb/src/models/zego_error.dart';
import 'package:zegoweb/src/zego_engine.dart';

import 'fixtures/fake_zego_js.dart';

void main() {
  group('ZegoEngine devices', () {
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

    test('getCameras returns mapped device infos', () async {
      fake.cameras = const [
        ('cam-1', 'Front Camera'),
        ('cam-2', 'Back Camera'),
      ];
      final devices = await engine.getCameras();
      expect(devices.map((d) => d.deviceId), ['cam-1', 'cam-2']);
      expect(devices.first.deviceName, 'Front Camera');
    });

    test('getMicrophones returns mapped device infos', () async {
      fake.microphones = const [('mic-1', 'Built-in')];
      final devices = await engine.getMicrophones();
      expect(devices.single.deviceId, 'mic-1');
    });

    test('useCamera forwards deviceId to JS useVideoDevice', () async {
      fake.nextCreatedStreamId = 'l1';
      await engine.createLocalStream();
      await engine.useCamera('cam-1');
      expect(fake.usedCamera, 'cam-1');
    });

    test('useCamera without a local stream throws ZegoStateError', () async {
      await expectLater(
        engine.useCamera('cam-1'),
        throwsA(isA<ZegoStateError>()),
      );
    });

    test('useMicrophone forwards to JS useAudioDevice', () async {
      fake.nextCreatedStreamId = 'l1';
      await engine.createLocalStream();
      await engine.useMicrophone('mic-1');
      expect(fake.usedMic, 'mic-1');
    });

    test('muteMicrophone forwards to JS mutePublishStreamAudio', () async {
      fake.nextCreatedStreamId = 'l1';
      await engine.createLocalStream();
      await engine.muteMicrophone(true);
      expect(fake.lastMuteMic, isTrue);
    });

    test('enableCamera forwards to JS enableVideoCaptureDevice', () async {
      fake.nextCreatedStreamId = 'l1';
      await engine.createLocalStream();
      await engine.enableCamera(false);
      expect(fake.lastEnableCam, isFalse);
    });

    test('checkPermissions returns a valid enum value in the chrome runner',
        () async {
      final status = await engine.checkPermissions();
      expect(status, isA<ZegoPermissionStatus>());
    });
  });
}
