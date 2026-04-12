import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb_prebuilt/src/zego_prebuilt_config.dart';

void main() {
  group('ZegoPrebuiltConfig', () {
    test('defaults match UIKit defaults', () {
      const config = ZegoPrebuiltConfig(roomId: 'r1', userId: 'u1');
      expect(config.scenario, ZegoPrebuiltScenario.oneOnOneCall);
      expect(config.maxUsers, isNull);
      expect(config.showPreJoinView, isTrue);
      expect(config.preJoinViewTitle, isNull);
      expect(config.turnOnMicrophoneWhenJoining, isTrue);
      expect(config.turnOnCameraWhenJoining, isTrue);
      expect(config.useFrontFacingCamera, isTrue);
      expect(config.videoResolution, ZegoPrebuiltVideoResolution.hd720);
      expect(config.layout, ZegoPrebuiltLayout.auto);
      expect(config.showRoomTimer, isFalse);
      expect(config.showMyCameraToggleButton, isTrue);
      expect(config.showMyMicrophoneToggleButton, isTrue);
      expect(config.showAudioVideoSettingsButton, isTrue);
      expect(config.showTextChat, isTrue);
      expect(config.showUserList, isTrue);
      expect(config.showScreenSharingButton, isTrue);
      expect(config.showLeaveRoomConfirmDialog, isTrue);
      expect(config.brandingLogoUrl, isNull);
      expect(config.language, ZegoPrebuiltLanguage.english);
      expect(config.rawConfig, isNull);
    });

    test('stores roomId and userId', () {
      const config = ZegoPrebuiltConfig(roomId: 'room-1', userId: 'user-1');
      expect(config.roomId, 'room-1');
      expect(config.userId, 'user-1');
    });

    test('rawConfig is preserved', () {
      const config = ZegoPrebuiltConfig(
        roomId: 'r1',
        userId: 'u1',
        rawConfig: {'showNonVideoUser': false},
      );
      expect(config.rawConfig, {'showNonVideoUser': false});
    });

    test('all typed fields can be overridden', () {
      const config = ZegoPrebuiltConfig(
        roomId: 'r1',
        userId: 'u1',
        userName: 'Alice',
        scenario: ZegoPrebuiltScenario.videoConference,
        maxUsers: 50,
        showPreJoinView: false,
        preJoinViewTitle: 'Join Meeting',
        turnOnMicrophoneWhenJoining: false,
        turnOnCameraWhenJoining: false,
        useFrontFacingCamera: false,
        videoResolution: ZegoPrebuiltVideoResolution.sd360,
        layout: ZegoPrebuiltLayout.grid,
        showRoomTimer: true,
        showMyCameraToggleButton: false,
        showMyMicrophoneToggleButton: false,
        showAudioVideoSettingsButton: false,
        showTextChat: false,
        showUserList: false,
        showScreenSharingButton: false,
        showLeaveRoomConfirmDialog: false,
        brandingLogoUrl: 'https://example.com/logo.png',
        language: ZegoPrebuiltLanguage.chinese,
      );
      expect(config.scenario, ZegoPrebuiltScenario.videoConference);
      expect(config.maxUsers, 50);
      expect(config.showPreJoinView, isFalse);
      expect(config.turnOnCameraWhenJoining, isFalse);
      expect(config.layout, ZegoPrebuiltLayout.grid);
      expect(config.showRoomTimer, isTrue);
      expect(config.showTextChat, isFalse);
      expect(config.language, ZegoPrebuiltLanguage.chinese);
      expect(config.brandingLogoUrl, 'https://example.com/logo.png');
    });
  });
}
