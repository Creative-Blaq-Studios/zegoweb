import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb_ui/src/widgets/zego_control_circle.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('ZegoControlCircle', () {
    testWidgets('renders the icon', (tester) async {
      await tester.pumpWidget(_wrap(
        ZegoControlCircle(
          icon: Icons.screen_share,
          color: Colors.white,
          backgroundColor: const Color(0xFF3C4043),
          onPressed: () {},
        ),
      ));

      expect(find.byIcon(Icons.screen_share), findsOneWidget);
    });

    testWidgets('applies background color', (tester) async {
      const bgColor = Color(0xFF3C4043);

      await tester.pumpWidget(_wrap(
        ZegoControlCircle(
          icon: Icons.grid_view,
          color: Colors.white,
          backgroundColor: bgColor,
          onPressed: () {},
        ),
      ));

      final container = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(ZegoControlCircle),
          matching: find.byType(DecoratedBox),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, bgColor);
    });

    testWidgets('fires onPressed on tap', (tester) async {
      var tapped = false;

      await tester.pumpWidget(_wrap(
        ZegoControlCircle(
          icon: Icons.screen_share,
          color: Colors.white,
          backgroundColor: const Color(0xFF3C4043),
          onPressed: () => tapped = true,
        ),
      ));

      await tester.tap(find.byType(ZegoControlCircle));
      expect(tapped, isTrue);
    });
  });
}
