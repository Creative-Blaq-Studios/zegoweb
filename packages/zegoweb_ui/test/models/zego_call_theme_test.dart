import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb_ui/src/zego_call_theme.dart';

void main() {
  group('ZegoCallTheme', () {
    test('all fields default to null', () {
      const theme = ZegoCallTheme();
      expect(theme.backgroundColor, isNull);
      expect(theme.tileBackgroundColor, isNull);
      expect(theme.tileBorderRadius, isNull);
      expect(theme.controlsBarColor, isNull);
      expect(theme.activeControlColor, isNull);
      expect(theme.inactiveControlColor, isNull);
      expect(theme.hangUpColor, isNull);
      expect(theme.nameTextStyle, isNull);
      expect(theme.micIndicatorColor, isNull);
    });

    test('copyWith preserves unchanged fields', () {
      const theme = ZegoCallTheme(backgroundColor: Colors.black, hangUpColor: Colors.red);
      final copied = theme.copyWith(hangUpColor: Colors.pink);
      expect(copied.backgroundColor, Colors.black);
      expect(copied.hangUpColor, Colors.pink);
    });

    test('lerp interpolates colors', () {
      const a = ZegoCallTheme(backgroundColor: Colors.black);
      const b = ZegoCallTheme(backgroundColor: Colors.white);
      final mid = a.lerp(b, 0.5);
      expect(mid.backgroundColor, isNotNull);
      expect(mid.backgroundColor, isNot(Colors.black));
      expect(mid.backgroundColor, isNot(Colors.white));
    });

    test('resolve returns defaults from ColorScheme when no extension', () {
      final colorScheme = ColorScheme.fromSeed(seedColor: Colors.indigo);
      final resolved = ZegoCallTheme.resolve(null, colorScheme, Typography.material2021().englishLike);
      expect(resolved.backgroundColor, colorScheme.surface);
      expect(resolved.hangUpColor, colorScheme.error);
      expect(resolved.tileBorderRadius, 12.0);
      expect(resolved.activeControlColor, colorScheme.onSurface);
    });

    test('resolve merges extension over defaults', () {
      final colorScheme = ColorScheme.fromSeed(seedColor: Colors.indigo);
      const ext = ZegoCallTheme(hangUpColor: Colors.orange);
      final resolved = ZegoCallTheme.resolve(ext, colorScheme, Typography.material2021().englishLike);
      expect(resolved.hangUpColor, Colors.orange);
      expect(resolved.backgroundColor, colorScheme.surface);
    });

    test('is a ThemeExtension', () {
      const theme = ZegoCallTheme();
      expect(theme, isA<ThemeExtension<ZegoCallTheme>>());
    });
  });
}
