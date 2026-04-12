import 'package:flutter/material.dart';
import 'package:zegoweb_ui/src/zego_call_config.dart';
import 'package:zegoweb_ui/src/zego_call_theme.dart';

/// A horizontal row of circular icon buttons for call controls.
///
/// Visibility of each button is controlled by the [config]'s `show*` flags.
/// The hang-up button (red, [Icons.call_end]) is always shown.
///
/// Icon states toggle between on/off variants based on [isMicOn],
/// [isCameraOn], and [isScreenSharing].
class ZegoControlsBar extends StatelessWidget {
  const ZegoControlsBar({
    super.key,
    required this.config,
    required this.isMicOn,
    required this.isCameraOn,
    required this.isScreenSharing,
    required this.onToggleMic,
    required this.onToggleCamera,
    required this.onToggleScreenShare,
    required this.onDevicePicker,
    required this.onLayoutSwitcher,
    required this.onHangUp,
  });

  /// Call configuration that determines which buttons are visible.
  final ZegoCallConfig config;

  /// Current microphone state.
  final bool isMicOn;

  /// Current camera state.
  final bool isCameraOn;

  /// Current screen sharing state.
  final bool isScreenSharing;

  /// Called when the microphone toggle button is tapped.
  final VoidCallback onToggleMic;

  /// Called when the camera toggle button is tapped.
  final VoidCallback onToggleCamera;

  /// Called when the screen share toggle button is tapped.
  final VoidCallback onToggleScreenShare;

  /// Called when the device picker button is tapped.
  final VoidCallback onDevicePicker;

  /// Called when the layout switcher button is tapped.
  final VoidCallback onLayoutSwitcher;

  /// Called when the hang up button is tapped.
  final VoidCallback onHangUp;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final themeExt = Theme.of(context).extension<ZegoCallTheme>();
    final theme = ZegoCallTheme.resolve(themeExt, colorScheme, textTheme);

    final buttons = <Widget>[];

    if (config.showMicrophoneToggle) {
      buttons.add(_controlButton(
        icon: isMicOn ? Icons.mic : Icons.mic_off,
        color: isMicOn ? theme.activeControlColor : theme.inactiveControlColor,
        onPressed: onToggleMic,
      ));
    }

    if (config.showCameraToggle) {
      buttons.add(_controlButton(
        icon: isCameraOn ? Icons.videocam : Icons.videocam_off,
        color:
            isCameraOn ? theme.activeControlColor : theme.inactiveControlColor,
        onPressed: onToggleCamera,
      ));
    }

    if (config.showScreenShareButton) {
      buttons.add(_controlButton(
        icon: isScreenSharing ? Icons.stop_screen_share : Icons.screen_share,
        color: isScreenSharing
            ? theme.activeControlColor
            : theme.inactiveControlColor,
        onPressed: onToggleScreenShare,
      ));
    }

    if (config.showDevicePicker) {
      buttons.add(_controlButton(
        icon: Icons.settings,
        color: theme.activeControlColor,
        onPressed: onDevicePicker,
      ));
    }

    if (config.showLayoutSwitcher) {
      buttons.add(_controlButton(
        icon: Icons.grid_view,
        color: theme.activeControlColor,
        onPressed: onLayoutSwitcher,
      ));
    }

    // Hang up button is always shown.
    buttons.add(_controlButton(
      icon: Icons.call_end,
      color: Colors.white,
      backgroundColor: theme.hangUpColor ?? Colors.red,
      onPressed: onHangUp,
    ));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: theme.controlsBarColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children:
            buttons.expand((btn) => [btn, const SizedBox(width: 12)]).toList()
              ..removeLast(),
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required Color? color,
    Color? backgroundColor,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      color: color,
      style: backgroundColor != null
          ? IconButton.styleFrom(backgroundColor: backgroundColor)
          : null,
    );
  }
}
