@TestOn('chrome')
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb/zegoweb.dart';
import 'package:zegoweb_ui/src/zego_call_config.dart';
import 'package:zegoweb_ui/src/zego_call_controller.dart';
import 'package:zegoweb_ui/src/zego_call_state.dart';
import 'package:zegoweb_ui/src/zego_layout_mode.dart';

void main() {
  group('ZegoCallController', () {
    late ZegoCallController controller;

    setUp(() {
      controller = ZegoCallController(
        engineConfig: ZegoEngineConfig(
          appId: 1,
          server: 'wss://example.com',
          scenario: ZegoScenario.communication,
          tokenProvider: () async => 'token',
        ),
        callConfig: const ZegoCallConfig(roomId: 'r1', userId: 'u1'),
      );
    });

    tearDown(() => controller.dispose());

    test('initial state is idle', () {
      expect(controller.state, ZegoCallState.idle);
    });

    test('initial participants is empty', () {
      expect(controller.participants, isEmpty);
    });

    test('initial layout comes from config', () {
      expect(controller.currentLayout, ZegoLayoutMode.grid);
    });

    test('initial mic and camera are on', () {
      expect(controller.isMicOn, isTrue);
      expect(controller.isCameraOn, isTrue);
    });

    test('initial isScreenSharing is false', () {
      expect(controller.isScreenSharing, isFalse);
    });

    test('switchLayout changes currentLayout and notifies', () {
      var notified = false;
      controller.addListener(() => notified = true);
      controller.switchLayout(ZegoLayoutMode.sidebar);
      expect(controller.currentLayout, ZegoLayoutMode.sidebar);
      expect(notified, isTrue);
    });

    test('switchLayout cycles through all modes', () {
      controller.switchLayout(ZegoLayoutMode.sidebar);
      expect(controller.currentLayout, ZegoLayoutMode.sidebar);
      controller.switchLayout(ZegoLayoutMode.pip);
      expect(controller.currentLayout, ZegoLayoutMode.pip);
      controller.switchLayout(ZegoLayoutMode.grid);
      expect(controller.currentLayout, ZegoLayoutMode.grid);
    });

    test('is a ChangeNotifier', () {
      expect(controller, isA<ChangeNotifier>());
    });
  });
}
