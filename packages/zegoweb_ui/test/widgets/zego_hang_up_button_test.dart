import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb_ui/src/widgets/zego_hang_up_button.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('ZegoHangUpButton', () {
    testWidgets('renders call_end icon', (tester) async {
      await tester.pumpWidget(_wrap(
        ZegoHangUpButton(onPressed: () {}),
      ));

      expect(find.byIcon(Icons.call_end), findsOneWidget);
    });

    testWidgets('has pill shape (StadiumBorder)', (tester) async {
      await tester.pumpWidget(_wrap(
        ZegoHangUpButton(onPressed: () {}),
      ));

      final button = tester.widget<IconButton>(find.byType(IconButton));
      final shape = button.style?.shape?.resolve({});
      expect(shape, isA<StadiumBorder>());
    });

    testWidgets('fires onPressed on tap', (tester) async {
      var tapped = false;

      await tester.pumpWidget(_wrap(
        ZegoHangUpButton(onPressed: () => tapped = true),
      ));

      await tester.tap(find.byType(ZegoHangUpButton));
      expect(tapped, isTrue);
    });

    testWidgets('uses custom hangUpColor when provided', (tester) async {
      const customColor = Color(0xFFFF0000);

      await tester.pumpWidget(_wrap(
        ZegoHangUpButton(
          onPressed: () {},
          backgroundColor: customColor,
        ),
      ));

      final button = tester.widget<IconButton>(find.byType(IconButton));
      final bgColor = button.style?.backgroundColor?.resolve({});
      expect(bgColor, customColor);
    });
  });
}
