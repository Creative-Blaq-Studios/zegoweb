import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb_ui/src/zego_call_config.dart';

void main() {
  group('ZegoCallConfig', () {
    test('streamIdBuilder defaults to null', () {
      const cfg = ZegoCallConfig(roomId: 'r1', userId: 'u1');
      expect(cfg.streamIdBuilder, isNull);
    });

    test('streamIdBuilder can be provided via constructor', () {
      String builder(String r, String u) => 'custom-$r-$u';
      final cfg = ZegoCallConfig(
        roomId: 'r1',
        userId: 'u1',
        streamIdBuilder: builder,
      );
      expect(cfg.streamIdBuilder, same(builder));
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
