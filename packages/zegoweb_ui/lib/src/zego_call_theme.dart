import 'package:flutter/material.dart';

@immutable
class ZegoCallTheme extends ThemeExtension<ZegoCallTheme> {
  const ZegoCallTheme({
    this.backgroundColor,
    this.tileBackgroundColor,
    this.tileBorderRadius,
    this.controlsBarColor,
    this.activeControlColor,
    this.inactiveControlColor,
    this.hangUpColor,
    this.controlPillColor,
    this.controlPillMutedColor,
    this.controlCircleColor,
    this.controlMutedIconColor,
    this.devicePopoverColor,
    this.nameTextStyle,
    this.micIndicatorColor,
  });

  final Color? backgroundColor;
  final Color? tileBackgroundColor;
  final double? tileBorderRadius;
  final Color? controlsBarColor;
  final Color? activeControlColor;
  final Color? inactiveControlColor;
  final Color? hangUpColor;
  final Color? controlPillColor;
  final Color? controlPillMutedColor;
  final Color? controlCircleColor;
  final Color? controlMutedIconColor;
  final Color? devicePopoverColor;
  final TextStyle? nameTextStyle;
  final Color? micIndicatorColor;

  static ZegoCallTheme resolve(
    ZegoCallTheme? extension,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return ZegoCallTheme(
      backgroundColor: extension?.backgroundColor ?? colorScheme.surface,
      tileBackgroundColor:
          extension?.tileBackgroundColor ?? colorScheme.surfaceContainerHighest,
      tileBorderRadius: extension?.tileBorderRadius ?? 12.0,
      controlsBarColor:
          extension?.controlsBarColor ?? colorScheme.surfaceContainer,
      activeControlColor:
          extension?.activeControlColor ?? colorScheme.onSurface,
      inactiveControlColor:
          extension?.inactiveControlColor ?? colorScheme.onSurfaceVariant,
      hangUpColor: extension?.hangUpColor ??
          (colorScheme.brightness == Brightness.dark
              ? colorScheme.errorContainer
              : colorScheme.error),
      controlPillColor:
          extension?.controlPillColor ?? colorScheme.surfaceContainerHighest,
      controlPillMutedColor:
          extension?.controlPillMutedColor ?? const Color(0x40EA4335),
      controlCircleColor:
          extension?.controlCircleColor ?? colorScheme.surfaceContainerHighest,
      controlMutedIconColor:
          extension?.controlMutedIconColor ?? const Color(0xFFF28B82),
      devicePopoverColor:
          extension?.devicePopoverColor ?? colorScheme.surfaceContainerHigh,
      nameTextStyle: extension?.nameTextStyle ??
          textTheme.labelSmall?.copyWith(color: colorScheme.onSurface),
      micIndicatorColor: extension?.micIndicatorColor ?? colorScheme.primary,
    );
  }

  @override
  ZegoCallTheme copyWith({
    Color? backgroundColor,
    Color? tileBackgroundColor,
    double? tileBorderRadius,
    Color? controlsBarColor,
    Color? activeControlColor,
    Color? inactiveControlColor,
    Color? hangUpColor,
    Color? controlPillColor,
    Color? controlPillMutedColor,
    Color? controlCircleColor,
    Color? controlMutedIconColor,
    Color? devicePopoverColor,
    TextStyle? nameTextStyle,
    Color? micIndicatorColor,
  }) {
    return ZegoCallTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      tileBackgroundColor: tileBackgroundColor ?? this.tileBackgroundColor,
      tileBorderRadius: tileBorderRadius ?? this.tileBorderRadius,
      controlsBarColor: controlsBarColor ?? this.controlsBarColor,
      activeControlColor: activeControlColor ?? this.activeControlColor,
      inactiveControlColor: inactiveControlColor ?? this.inactiveControlColor,
      hangUpColor: hangUpColor ?? this.hangUpColor,
      controlPillColor: controlPillColor ?? this.controlPillColor,
      controlPillMutedColor:
          controlPillMutedColor ?? this.controlPillMutedColor,
      controlCircleColor: controlCircleColor ?? this.controlCircleColor,
      controlMutedIconColor:
          controlMutedIconColor ?? this.controlMutedIconColor,
      devicePopoverColor: devicePopoverColor ?? this.devicePopoverColor,
      nameTextStyle: nameTextStyle ?? this.nameTextStyle,
      micIndicatorColor: micIndicatorColor ?? this.micIndicatorColor,
    );
  }

  @override
  ZegoCallTheme lerp(ZegoCallTheme? other, double t) {
    if (other == null) return this;
    return ZegoCallTheme(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      tileBackgroundColor:
          Color.lerp(tileBackgroundColor, other.tileBackgroundColor, t),
      tileBorderRadius:
          _lerpDouble(tileBorderRadius, other.tileBorderRadius, t),
      controlsBarColor: Color.lerp(controlsBarColor, other.controlsBarColor, t),
      activeControlColor:
          Color.lerp(activeControlColor, other.activeControlColor, t),
      inactiveControlColor:
          Color.lerp(inactiveControlColor, other.inactiveControlColor, t),
      hangUpColor: Color.lerp(hangUpColor, other.hangUpColor, t),
      controlPillColor:
          Color.lerp(controlPillColor, other.controlPillColor, t),
      controlPillMutedColor:
          Color.lerp(controlPillMutedColor, other.controlPillMutedColor, t),
      controlCircleColor:
          Color.lerp(controlCircleColor, other.controlCircleColor, t),
      controlMutedIconColor:
          Color.lerp(controlMutedIconColor, other.controlMutedIconColor, t),
      devicePopoverColor:
          Color.lerp(devicePopoverColor, other.devicePopoverColor, t),
      nameTextStyle: TextStyle.lerp(nameTextStyle, other.nameTextStyle, t),
      micIndicatorColor:
          Color.lerp(micIndicatorColor, other.micIndicatorColor, t),
    );
  }

  static double? _lerpDouble(double? a, double? b, double t) {
    if (a == null && b == null) return null;
    a ??= 0.0;
    b ??= 0.0;
    return a + (b - a) * t;
  }
}
