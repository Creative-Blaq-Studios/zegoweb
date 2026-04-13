import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb/src/models/zego_device_info.dart';
import 'package:zegoweb_ui/src/widgets/zego_control_pill.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

const _devices = [
  ZegoDeviceInfo(deviceId: 'mic-1', deviceName: 'Built-in Mic'),
  ZegoDeviceInfo(deviceId: 'mic-2', deviceName: 'AirPods'),
];

void main() {
  group('ZegoControlPill', () {
    testWidgets('shows on-state icon when isOn is true', (tester) async {
      await tester.pumpWidget(_wrap(
        ZegoControlPill(
          icon: Icons.mic,
          offIcon: Icons.mic_off,
          isOn: true,
          onToggle: () {},
          devices: _devices,
          selectedDeviceId: 'mic-1',
          onDeviceSelected: (_) {},
          pillColor: const Color(0xFF3C4043),
          mutedPillColor: const Color(0x40EA4335),
          iconColor: Colors.white,
          mutedIconColor: const Color(0xFFF28B82),
        ),
      ));

      expect(find.byIcon(Icons.mic), findsOneWidget);
      expect(find.byIcon(Icons.mic_off), findsNothing);
    });

    testWidgets('shows off-state icon when isOn is false', (tester) async {
      await tester.pumpWidget(_wrap(
        ZegoControlPill(
          icon: Icons.mic,
          offIcon: Icons.mic_off,
          isOn: false,
          onToggle: () {},
          devices: _devices,
          selectedDeviceId: 'mic-1',
          onDeviceSelected: (_) {},
          pillColor: const Color(0xFF3C4043),
          mutedPillColor: const Color(0x40EA4335),
          iconColor: Colors.white,
          mutedIconColor: const Color(0xFFF28B82),
        ),
      ));

      expect(find.byIcon(Icons.mic_off), findsOneWidget);
      expect(find.byIcon(Icons.mic), findsNothing);
    });

    testWidgets('fires onToggle when icon side is tapped', (tester) async {
      var toggled = false;

      await tester.pumpWidget(_wrap(
        ZegoControlPill(
          icon: Icons.mic,
          offIcon: Icons.mic_off,
          isOn: true,
          onToggle: () => toggled = true,
          devices: _devices,
          selectedDeviceId: 'mic-1',
          onDeviceSelected: (_) {},
          pillColor: const Color(0xFF3C4043),
          mutedPillColor: const Color(0x40EA4335),
          iconColor: Colors.white,
          mutedIconColor: const Color(0xFFF28B82),
        ),
      ));

      await tester.tap(find.byIcon(Icons.mic));
      expect(toggled, isTrue);
    });

    testWidgets('chevron opens device popover when no override',
        (tester) async {
      await tester.pumpWidget(_wrap(
        ZegoControlPill(
          icon: Icons.mic,
          offIcon: Icons.mic_off,
          isOn: true,
          onToggle: () {},
          devices: _devices,
          selectedDeviceId: 'mic-1',
          onDeviceSelected: (_) {},
          pillColor: const Color(0xFF3C4043),
          mutedPillColor: const Color(0x40EA4335),
          iconColor: Colors.white,
          mutedIconColor: const Color(0xFFF28B82),
        ),
      ));

      // Tap the chevron (expand_less icon when closed).
      await tester.tap(find.byIcon(Icons.expand_less));
      await tester.pumpAndSettle();

      // Popover should show device names.
      expect(find.text('Built-in Mic'), findsOneWidget);
      expect(find.text('AirPods'), findsOneWidget);
    });

    testWidgets('chevron fires onChevronTap override instead of popover',
        (tester) async {
      var overrideCalled = false;

      await tester.pumpWidget(_wrap(
        ZegoControlPill(
          icon: Icons.mic,
          offIcon: Icons.mic_off,
          isOn: true,
          onToggle: () {},
          devices: _devices,
          selectedDeviceId: 'mic-1',
          onDeviceSelected: (_) {},
          onChevronTap: () => overrideCalled = true,
          pillColor: const Color(0xFF3C4043),
          mutedPillColor: const Color(0x40EA4335),
          iconColor: Colors.white,
          mutedIconColor: const Color(0xFFF28B82),
        ),
      ));

      await tester.tap(find.byIcon(Icons.expand_less));
      await tester.pumpAndSettle();

      expect(overrideCalled, isTrue);
      // Popover should NOT have opened.
      expect(find.text('Built-in Mic'), findsNothing);
    });

    testWidgets('applies muted pill color when isOn is false', (tester) async {
      const mutedColor = Color(0x40EA4335);

      await tester.pumpWidget(_wrap(
        ZegoControlPill(
          icon: Icons.mic,
          offIcon: Icons.mic_off,
          isOn: false,
          onToggle: () {},
          devices: _devices,
          selectedDeviceId: 'mic-1',
          onDeviceSelected: (_) {},
          pillColor: const Color(0xFF3C4043),
          mutedPillColor: mutedColor,
          iconColor: Colors.white,
          mutedIconColor: const Color(0xFFF28B82),
        ),
      ));

      final container = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(ZegoControlPill),
          matching: find.byType(DecoratedBox),
        ).first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, mutedColor);
    });
  });
}
