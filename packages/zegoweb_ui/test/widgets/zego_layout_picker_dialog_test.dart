import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb_ui/src/zego_layout_mode.dart';
import 'package:zegoweb_ui/src/widgets/zego_layout_picker_dialog.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

void main() {
  group('ZegoLayoutPickerDialog', () {
    testWidgets('renders all layout options', (tester) async {
      await tester.pumpWidget(_wrap(ZegoLayoutPickerDialog(
        currentLayout: ZegoLayoutMode.grid,
        hideNoVideoTiles: false,
        onLayoutSelected: (_) {},
        onHideNoVideoTilesChanged: (_) {},
        onClose: () {},
      )));
      expect(find.text('Grid'), findsOneWidget);
      expect(find.text('Sidebar'), findsOneWidget);
      expect(find.text('Picture-in-picture'), findsOneWidget);
      expect(find.text('Spotlight'), findsOneWidget);
      expect(find.text('Gallery'), findsOneWidget);
      expect(find.text('Auto'), findsOneWidget);
    });

    testWidgets('calls onLayoutSelected when tapping a layout', (tester) async {
      ZegoLayoutMode? selected;
      await tester.pumpWidget(_wrap(ZegoLayoutPickerDialog(
        currentLayout: ZegoLayoutMode.grid,
        hideNoVideoTiles: false,
        onLayoutSelected: (mode) => selected = mode,
        onHideNoVideoTilesChanged: (_) {},
        onClose: () {},
      )));
      await tester.tap(find.text('Sidebar'));
      expect(selected, ZegoLayoutMode.sidebar);
    });

    testWidgets('calls onClose when tapping close button', (tester) async {
      var closed = false;
      await tester.pumpWidget(_wrap(ZegoLayoutPickerDialog(
        currentLayout: ZegoLayoutMode.grid,
        hideNoVideoTiles: false,
        onLayoutSelected: (_) {},
        onHideNoVideoTilesChanged: (_) {},
        onClose: () => closed = true,
      )));
      await tester.tap(find.byIcon(Icons.close));
      expect(closed, isTrue);
    });

    testWidgets('shows tile size slider', (tester) async {
      await tester.pumpWidget(_wrap(ZegoLayoutPickerDialog(
        currentLayout: ZegoLayoutMode.grid,
        hideNoVideoTiles: false,
        onLayoutSelected: (_) {},
        onHideNoVideoTilesChanged: (_) {},
        onClose: () {},
      )));
      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('shows hide tiles toggle', (tester) async {
      await tester.pumpWidget(_wrap(ZegoLayoutPickerDialog(
        currentLayout: ZegoLayoutMode.grid,
        hideNoVideoTiles: false,
        onLayoutSelected: (_) {},
        onHideNoVideoTilesChanged: (_) {},
        onClose: () {},
      )));
      expect(find.text('Hide tiles without video'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });
  });
}
