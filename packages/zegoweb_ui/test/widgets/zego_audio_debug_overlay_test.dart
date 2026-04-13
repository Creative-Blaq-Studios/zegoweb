@TestOn('chrome')
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb/zegoweb.dart';
import 'package:zegoweb_ui/src/zego_call_config.dart';
import 'package:zegoweb_ui/src/zego_call_controller.dart';
import 'package:zegoweb_ui/src/widgets/zego_audio_debug_overlay.dart';

ZegoCallController _makeController({bool debugMode = true}) {
  return ZegoCallController(
    engineConfig: ZegoEngineConfig(
      appId: 1,
      server: 'wss://example.com',
      scenario: ZegoScenario.communication,
      tokenProvider: () async => '',
    ),
    callConfig: ZegoCallConfig(
      roomId: 'r1',
      userId: 'u1',
      debugMode: debugMode,
    ),
  );
}

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(width: 800, height: 600, child: child),
    ),
  );
}

void main() {
  group('ZegoAudioDebugOverlay', () {
    late ZegoCallController controller;

    setUp(() => controller = _makeController());
    tearDown(() => controller.dispose());

    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(_wrap(
        Stack(children: [
          ZegoAudioDebugOverlay(controller: controller),
        ]),
      ));
      expect(find.byType(ZegoAudioDebugOverlay), findsOneWidget);
    });

    testWidgets('shows AUDIO DEBUG title in expanded state', (tester) async {
      await tester.pumpWidget(_wrap(
        Stack(children: [ZegoAudioDebugOverlay(controller: controller)]),
      ));
      expect(find.text('🔬 AUDIO DEBUG'), findsOneWidget);
    });

    testWidgets('minimize button collapses to pill', (tester) async {
      await tester.pumpWidget(_wrap(
        Stack(children: [ZegoAudioDebugOverlay(controller: controller)]),
      ));
      // The yellow minimize button (–) exists
      expect(find.text('–'), findsOneWidget);
      await tester.tap(find.text('–'));
      await tester.pump();
      // After minimize, the AUDIO DEBUG title should be gone
      expect(find.text('🔬 AUDIO DEBUG'), findsNothing);
      // The pill's expand arrow should appear
      expect(find.text('▲'), findsOneWidget);
    });

    testWidgets('tapping pill expands back to panel', (tester) async {
      await tester.pumpWidget(_wrap(
        Stack(children: [ZegoAudioDebugOverlay(controller: controller)]),
      ));
      await tester.tap(find.text('–'));
      await tester.pump();
      expect(find.text('🔬 AUDIO DEBUG'), findsNothing);

      // Tap the ▲ expand arrow in the pill
      await tester.tap(find.text('▲'));
      await tester.pump();
      expect(find.text('🔬 AUDIO DEBUG'), findsOneWidget);
    });
  });
}
