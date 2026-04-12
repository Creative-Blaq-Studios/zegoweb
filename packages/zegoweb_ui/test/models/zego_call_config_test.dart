import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb_ui/src/zego_call_config.dart';
import 'package:zegoweb_ui/src/zego_layout_mode.dart';

void main() {
  group('ZegoCallConfig', () {
    test('defaults match spec', () {
      const config = ZegoCallConfig(roomId: 'r1', userId: 'u1');
      expect(config.roomId, 'r1');
      expect(config.userId, 'u1');
      expect(config.userName, isNull);
      expect(config.layout, ZegoLayoutMode.grid);
      expect(config.showPreJoinView, isTrue);
      expect(config.showMicrophoneToggle, isTrue);
      expect(config.showCameraToggle, isTrue);
      expect(config.showScreenShareButton, isTrue);
      expect(config.showDevicePicker, isTrue);
      expect(config.showLayoutSwitcher, isTrue);
    });

    test('all fields can be overridden', () {
      const config = ZegoCallConfig(
        roomId: 'r1', userId: 'u1', userName: 'Alice',
        layout: ZegoLayoutMode.pip,
        showPreJoinView: false, showMicrophoneToggle: false,
        showCameraToggle: false, showScreenShareButton: false,
        showDevicePicker: false, showLayoutSwitcher: false,
      );
      expect(config.userName, 'Alice');
      expect(config.layout, ZegoLayoutMode.pip);
      expect(config.showPreJoinView, isFalse);
      expect(config.showMicrophoneToggle, isFalse);
      expect(config.showCameraToggle, isFalse);
      expect(config.showScreenShareButton, isFalse);
      expect(config.showDevicePicker, isFalse);
      expect(config.showLayoutSwitcher, isFalse);
    });
  });
}
