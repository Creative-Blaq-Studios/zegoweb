import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb/src/models/zego_device_info.dart';
import 'package:zegoweb_ui/src/widgets/zego_device_popover.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

const _devices = [
  ZegoDeviceInfo(deviceId: 'mic-1', deviceName: 'Built-in Microphone'),
  ZegoDeviceInfo(deviceId: 'mic-2', deviceName: 'AirPods Pro'),
  ZegoDeviceInfo(deviceId: 'mic-3', deviceName: 'Brio 100'),
];

void main() {
  group('ZegoDevicePopover', () {
    testWidgets('shows all device names', (tester) async {
      await tester.pumpWidget(_wrap(
        ZegoDevicePopover(
          devices: _devices,
          selectedDeviceId: 'mic-1',
          onDeviceSelected: (_) {},
        ),
      ));

      expect(find.text('Built-in Microphone'), findsOneWidget);
      expect(find.text('AirPods Pro'), findsOneWidget);
      expect(find.text('Brio 100'), findsOneWidget);
    });

    testWidgets('shows check icon next to selected device', (tester) async {
      await tester.pumpWidget(_wrap(
        ZegoDevicePopover(
          devices: _devices,
          selectedDeviceId: 'mic-2',
          onDeviceSelected: (_) {},
        ),
      ));

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('fires onDeviceSelected when a device is tapped',
        (tester) async {
      ZegoDeviceInfo? selected;

      await tester.pumpWidget(_wrap(
        ZegoDevicePopover(
          devices: _devices,
          selectedDeviceId: 'mic-1',
          onDeviceSelected: (device) => selected = device,
        ),
      ));

      await tester.tap(find.text('AirPods Pro'));
      expect(selected?.deviceId, 'mic-2');
    });

    testWidgets('renders empty state when no devices', (tester) async {
      await tester.pumpWidget(_wrap(
        ZegoDevicePopover(
          devices: const [],
          selectedDeviceId: '',
          onDeviceSelected: (_) {},
        ),
      ));

      expect(find.text('No devices found'), findsOneWidget);
    });
  });
}
