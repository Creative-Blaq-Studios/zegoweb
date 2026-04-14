import 'package:flutter/painting.dart';
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
      expect(config.layout, ZegoLayoutMode.auto);
      expect(config.videoFit, BoxFit.contain);
      expect(config.showPreJoinView, isTrue);
      expect(config.showMicrophoneToggle, isTrue);
      expect(config.showCameraToggle, isTrue);
      expect(config.showScreenShareButton, isFalse);
      expect(config.showLayoutPicker, isTrue);
      expect(config.hideNoVideoTiles, isFalse);
      expect(config.showAudioDebugOverlay, isFalse);
    });

    test('all fields can be overridden', () {
      const config = ZegoCallConfig(
        roomId: 'r1',
        userId: 'u1',
        userName: 'Alice',
        layout: ZegoLayoutMode.pip,
        videoFit: BoxFit.cover,
        showPreJoinView: false,
        showMicrophoneToggle: false,
        showCameraToggle: false,
        showScreenShareButton: false,
        showLayoutPicker: false,
        hideNoVideoTiles: true,
        showAudioDebugOverlay: true,
      );
      expect(config.userName, 'Alice');
      expect(config.layout, ZegoLayoutMode.pip);
      expect(config.videoFit, BoxFit.cover);
      expect(config.showPreJoinView, isFalse);
      expect(config.showMicrophoneToggle, isFalse);
      expect(config.showCameraToggle, isFalse);
      expect(config.showScreenShareButton, isFalse);
      expect(config.showLayoutPicker, isFalse);
      expect(config.hideNoVideoTiles, isTrue);
      expect(config.showAudioDebugOverlay, isTrue);
    });

    test('showAudioDebugOverlay defaults to false', () {
      const config = ZegoCallConfig(roomId: 'r1', userId: 'u1');
      expect(config.showAudioDebugOverlay, isFalse);
    });

    test('showAudioDebugOverlay can be set to true', () {
      const config = ZegoCallConfig(
        roomId: 'r1',
        userId: 'u1',
        showAudioDebugOverlay: true,
      );
      expect(config.showAudioDebugOverlay, isTrue);
    });
  });
}
