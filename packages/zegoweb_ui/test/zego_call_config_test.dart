import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb_ui/src/zego_call_config.dart';

void main() {
  group('ZegoCallConfig', () {
    test('streamIdBuilder defaults to null', () {
      const cfg = ZegoCallConfig(roomId: 'r1', userId: 'u1');
      expect(cfg.streamIdBuilder, isNull);
    });

    test('streamIdBuilder is invoked with the passed arguments', () {
      final cfg = ZegoCallConfig(
        roomId: 'r1',
        userId: 'u1',
        streamIdBuilder: (r, u) => 'custom-$r-$u',
      );
      expect(cfg.streamIdBuilder!('room42', 'bob'), 'custom-room42-bob');
    });

    test('defaultStreamIdBuilder returns {roomId}_{userId}_main', () {
      expect(ZegoCallConfig.defaultStreamIdBuilder('room42', 'bob'),
          'room42_bob_main');
    });

    test('defaultStreamIdBuilder handles empty strings verbatim', () {
      expect(ZegoCallConfig.defaultStreamIdBuilder('', ''), '__main');
    });
  });
}
