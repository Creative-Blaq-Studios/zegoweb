import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb_ui/src/zego_call_config.dart';
import 'package:zegoweb_ui/src/widgets/zego_control_circle.dart';
import 'package:zegoweb_ui/src/widgets/zego_control_pill.dart';
import 'package:zegoweb_ui/src/widgets/zego_controls_bar.dart';
import 'package:zegoweb_ui/src/widgets/zego_hang_up_button.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

const _defaultConfig = ZegoCallConfig(roomId: 'r1', userId: 'u1');

void main() {
  group('ZegoControlsBar', () {
    testWidgets('shows all controls by default', (tester) async {
      await tester.pumpWidget(_wrap(
        ZegoControlsBar(
          config: _defaultConfig,
          isMicOn: true,
          isCameraOn: true,
          isScreenSharing: false,
          onToggleMic: () {},
          onToggleCamera: () {},
          onToggleScreenShare: () {},
          onLayoutSwitcher: () {},
          onHangUp: () {},
          cameras: const [],
          microphones: const [],
          selectedCameraId: '',
          selectedMicrophoneId: '',
        ),
      ));

      // 2 pills (mic, camera) + 1 circle (layout; screen share off by default) + 1 hang up
      expect(find.byType(ZegoControlPill), findsNWidgets(2));
      expect(find.byType(ZegoControlCircle), findsOneWidget);
      expect(find.byType(ZegoHangUpButton), findsOneWidget);
    });

    testWidgets('hides mic pill when showMicrophoneToggle is false',
        (tester) async {
      const config = ZegoCallConfig(
        roomId: 'r1',
        userId: 'u1',
        showMicrophoneToggle: false,
      );

      await tester.pumpWidget(_wrap(
        ZegoControlsBar(
          config: config,
          isMicOn: true,
          isCameraOn: true,
          isScreenSharing: false,
          onToggleMic: () {},
          onToggleCamera: () {},
          onToggleScreenShare: () {},
          onLayoutSwitcher: () {},
          onHangUp: () {},
          cameras: const [],
          microphones: const [],
          selectedCameraId: '',
          selectedMicrophoneId: '',
        ),
      ));

      // Only 1 pill (camera), not 2.
      expect(find.byType(ZegoControlPill), findsOneWidget);
    });

    testWidgets('renders leading slot when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        ZegoControlsBar(
          config: _defaultConfig,
          isMicOn: true,
          isCameraOn: true,
          isScreenSharing: false,
          onToggleMic: () {},
          onToggleCamera: () {},
          onToggleScreenShare: () {},
          onLayoutSwitcher: () {},
          onHangUp: () {},
          cameras: const [],
          microphones: const [],
          selectedCameraId: '',
          selectedMicrophoneId: '',
          leadingBuilder: (_) => const Text('Meeting Info'),
        ),
      ));

      expect(find.text('Meeting Info'), findsOneWidget);
    });

    testWidgets('renders trailing slot when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        ZegoControlsBar(
          config: _defaultConfig,
          isMicOn: true,
          isCameraOn: true,
          isScreenSharing: false,
          onToggleMic: () {},
          onToggleCamera: () {},
          onToggleScreenShare: () {},
          onLayoutSwitcher: () {},
          onHangUp: () {},
          cameras: const [],
          microphones: const [],
          selectedCameraId: '',
          selectedMicrophoneId: '',
          trailingBuilder: (_) => const Text('Side Actions'),
        ),
      ));

      expect(find.text('Side Actions'), findsOneWidget);
    });

    testWidgets('hang up calls onHangUp', (tester) async {
      var called = false;

      await tester.pumpWidget(_wrap(
        ZegoControlsBar(
          config: _defaultConfig,
          isMicOn: true,
          isCameraOn: true,
          isScreenSharing: false,
          onToggleMic: () {},
          onToggleCamera: () {},
          onToggleScreenShare: () {},
          onLayoutSwitcher: () {},
          onHangUp: () => called = true,
          cameras: const [],
          microphones: const [],
          selectedCameraId: '',
          selectedMicrophoneId: '',
        ),
      ));

      await tester.tap(find.byType(ZegoHangUpButton));
      expect(called, isTrue);
    });
  });
}
