import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb_ui/src/zego_layout_mode.dart';

void main() {
  group('ZegoLayoutMode', () {
    test('has grid, sidebar, pip in order', () {
      expect(ZegoLayoutMode.values, [
        ZegoLayoutMode.grid,
        ZegoLayoutMode.sidebar,
        ZegoLayoutMode.pip,
      ]);
    });
  });
}
