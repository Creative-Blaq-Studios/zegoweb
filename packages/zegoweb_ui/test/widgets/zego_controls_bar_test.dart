import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb_ui/src/zego_call_config.dart';
import 'package:zegoweb_ui/src/widgets/zego_controls_bar.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
  );
}

void main() {
  group('ZegoControlsBar', () {
    testWidgets('shows all buttons by default', (tester) async {
      const config = ZegoCallConfig(roomId: 'r1', userId: 'u1');

      await tester.pumpWidget(_wrap(
        ZegoControlsBar(
          config: config,
          isMicOn: true,
          isCameraOn: true,
          isScreenSharing: false,
          onToggleMic: () {},
          onToggleCamera: () {},
          onToggleScreenShare: () {},
          onDevicePicker: () {},
          onLayoutSwitcher: () {},
          onHangUp: () {},
        ),
      ));

      // mic, videocam, screen_share, settings, grid_view, call_end
      expect(find.byIcon(Icons.mic), findsOneWidget);
      expect(find.byIcon(Icons.videocam), findsOneWidget);
      expect(find.byIcon(Icons.screen_share), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.byIcon(Icons.grid_view), findsOneWidget);
      expect(find.byIcon(Icons.call_end), findsOneWidget);
    });

    testWidgets('hides mic when showMicrophoneToggle is false',
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
          onDevicePicker: () {},
          onLayoutSwitcher: () {},
          onHangUp: () {},
        ),
      ));

      expect(find.byIcon(Icons.mic), findsNothing);
      expect(find.byIcon(Icons.mic_off), findsNothing);
      // call_end is always shown
      expect(find.byIcon(Icons.call_end), findsOneWidget);
    });

    testWidgets('shows mic_off when mic is off', (tester) async {
      const config = ZegoCallConfig(roomId: 'r1', userId: 'u1');

      await tester.pumpWidget(_wrap(
        ZegoControlsBar(
          config: config,
          isMicOn: false,
          isCameraOn: true,
          isScreenSharing: false,
          onToggleMic: () {},
          onToggleCamera: () {},
          onToggleScreenShare: () {},
          onDevicePicker: () {},
          onLayoutSwitcher: () {},
          onHangUp: () {},
        ),
      ));

      expect(find.byIcon(Icons.mic_off), findsOneWidget);
      expect(find.byIcon(Icons.mic), findsNothing);
    });

    testWidgets('calls onHangUp callback', (tester) async {
      const config = ZegoCallConfig(roomId: 'r1', userId: 'u1');
      var hangUpCalled = false;

      await tester.pumpWidget(_wrap(
        ZegoControlsBar(
          config: config,
          isMicOn: true,
          isCameraOn: true,
          isScreenSharing: false,
          onToggleMic: () {},
          onToggleCamera: () {},
          onToggleScreenShare: () {},
          onDevicePicker: () {},
          onLayoutSwitcher: () {},
          onHangUp: () => hangUpCalled = true,
        ),
      ));

      await tester.tap(find.byIcon(Icons.call_end));
      expect(hangUpCalled, isTrue);
    });

    testWidgets('shows videocam_off when camera is off', (tester) async {
      const config = ZegoCallConfig(roomId: 'r1', userId: 'u1');

      await tester.pumpWidget(_wrap(
        ZegoControlsBar(
          config: config,
          isMicOn: true,
          isCameraOn: false,
          isScreenSharing: false,
          onToggleMic: () {},
          onToggleCamera: () {},
          onToggleScreenShare: () {},
          onDevicePicker: () {},
          onLayoutSwitcher: () {},
          onHangUp: () {},
        ),
      ));

      expect(find.byIcon(Icons.videocam_off), findsOneWidget);
      expect(find.byIcon(Icons.videocam), findsNothing);
    });

    testWidgets('shows stop_screen_share when screen sharing',
        (tester) async {
      const config = ZegoCallConfig(roomId: 'r1', userId: 'u1');

      await tester.pumpWidget(_wrap(
        ZegoControlsBar(
          config: config,
          isMicOn: true,
          isCameraOn: true,
          isScreenSharing: true,
          onToggleMic: () {},
          onToggleCamera: () {},
          onToggleScreenShare: () {},
          onDevicePicker: () {},
          onLayoutSwitcher: () {},
          onHangUp: () {},
        ),
      ));

      expect(find.byIcon(Icons.stop_screen_share), findsOneWidget);
      expect(find.byIcon(Icons.screen_share), findsNothing);
    });
  });
}
