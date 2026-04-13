@TestOn('chrome')
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb/zegoweb.dart';
import 'package:zegoweb_ui/src/zego_call_config.dart';
import 'package:zegoweb_ui/src/zego_call_screen.dart';
import 'package:zegoweb_ui/src/widgets/zego_audio_debug_overlay.dart';
import 'package:zegoweb_ui/src/widgets/zego_pre_join_view.dart';

Widget _wrap(Widget child) {
  return MaterialApp(home: child);
}

void main() {
  group('ZegoCallScreen', () {
    testWidgets('shows pre-join view initially when showPreJoinView is true',
        (tester) async {
      await tester.pumpWidget(_wrap(ZegoCallScreen(
        engineConfig: ZegoEngineConfig(
          appId: 1,
          server: 'wss://example.com',
          scenario: ZegoScenario.communication,
          tokenProvider: () async => '',
        ),
        callConfig: const ZegoCallConfig(
          roomId: 'r1',
          userId: 'u1',
          userName: 'Alice',
          showPreJoinView: true,
        ),
      )));
      expect(find.byType(ZegoPreJoinView), findsOneWidget);
    });

    testWidgets('shows Join button text', (tester) async {
      await tester.pumpWidget(_wrap(ZegoCallScreen(
        engineConfig: ZegoEngineConfig(
          appId: 1,
          server: 'wss://example.com',
          scenario: ZegoScenario.communication,
          tokenProvider: () async => '',
        ),
        callConfig: const ZegoCallConfig(
          roomId: 'r1',
          userId: 'u1',
          userName: 'Alice',
        ),
      )));
      expect(find.text('Join now'), findsOneWidget);
    });

    testWidgets('does not show debug overlay when debugMode is false',
        (tester) async {
      await tester.pumpWidget(_wrap(ZegoCallScreen(
        engineConfig: ZegoEngineConfig(
          appId: 1,
          server: 'wss://example.com',
          scenario: ZegoScenario.communication,
          tokenProvider: () async => '',
        ),
        callConfig: const ZegoCallConfig(
          roomId: 'r1',
          userId: 'u1',
          debugMode: false,
        ),
      )));
      expect(find.byType(ZegoAudioDebugOverlay), findsNothing);
    });

    testWidgets('shows debug overlay when debugMode is true', (tester) async {
      await tester.pumpWidget(_wrap(ZegoCallScreen(
        engineConfig: ZegoEngineConfig(
          appId: 1,
          server: 'wss://example.com',
          scenario: ZegoScenario.communication,
          tokenProvider: () async => '',
        ),
        callConfig: const ZegoCallConfig(
          roomId: 'r1',
          userId: 'u1',
          debugMode: true,
        ),
      )));
      expect(find.byType(ZegoAudioDebugOverlay), findsOneWidget);
    });
  });
}
