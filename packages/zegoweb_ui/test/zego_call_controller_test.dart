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

    group('debug surface', () {
      test('debugThreshold defaults to 10.0', () {
        expect(controller.debugThreshold, 10.0);
      });

      test('debugThreshold setter clamps to 0–100', () {
        controller.debugThreshold = 25.0;
        expect(controller.debugThreshold, 25.0);

        controller.debugThreshold = -5.0;
        expect(controller.debugThreshold, 0.0);

        controller.debugThreshold = 150.0;
        expect(controller.debugThreshold, 100.0);
      });

      test('debugThreshold setter notifies listeners', () {
        var notified = false;
        controller.addListener(() => notified = true);
        controller.debugThreshold = 20.0;
        expect(notified, isTrue);
      });

      test('debugDebounce defaults to 500 ms', () {
        expect(controller.debugDebounce, const Duration(milliseconds: 500));
      });

      test('debugDebounce setter stores value', () {
        controller.debugDebounce = const Duration(milliseconds: 800);
        expect(controller.debugDebounce, const Duration(milliseconds: 800));
      });

      test('debugLog is a broadcast stream', () {
        expect(controller.debugLog.isBroadcast, isTrue);
      });

      test('debugLog allows multiple subscribers', () {
        final sub1 = controller.debugLog.listen((_) {});
        final sub2 = controller.debugLog.listen((_) {});
        sub1.cancel();
        sub2.cancel();
      });

      test('debugMicLevel returns a stream', () {
        expect(controller.debugMicLevel, isA<Stream<double>>());
      });
    });
  });
}
