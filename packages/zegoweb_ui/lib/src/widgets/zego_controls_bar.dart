import 'package:flutter/material.dart';
import 'package:zegoweb/src/models/zego_device_info.dart';

import 'package:zegoweb_ui/src/zego_call_config.dart';
import 'package:zegoweb_ui/src/zego_call_theme.dart';
import 'package:zegoweb_ui/src/widgets/zego_control_circle.dart';
import 'package:zegoweb_ui/src/widgets/zego_control_pill.dart';
import 'package:zegoweb_ui/src/widgets/zego_hang_up_button.dart';

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
    required this.onLayoutSwitcher,
    required this.onHangUp,
    required this.cameras,
    required this.microphones,
    required this.selectedCameraId,
    required this.selectedMicrophoneId,
    this.onCameraSelected,
    this.onMicrophoneSelected,
    this.onMicChevron,
    this.onCameraChevron,
    this.leadingBuilder,
    this.trailingBuilder,
  });

  final ZegoCallConfig config;
  final bool isMicOn;
  final bool isCameraOn;
  final bool isScreenSharing;
  final VoidCallback onToggleMic;
  final VoidCallback onToggleCamera;
  final VoidCallback onToggleScreenShare;
  final VoidCallback onLayoutSwitcher;
  final VoidCallback onHangUp;
  final List<ZegoDeviceInfo> cameras;
  final List<ZegoDeviceInfo> microphones;
  final String selectedCameraId;
  final String selectedMicrophoneId;
  final ValueChanged<ZegoDeviceInfo>? onCameraSelected;
  final ValueChanged<ZegoDeviceInfo>? onMicrophoneSelected;
  final VoidCallback? onMicChevron;
  final VoidCallback? onCameraChevron;
  final WidgetBuilder? leadingBuilder;
  final WidgetBuilder? trailingBuilder;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final themeExt = Theme.of(context).extension<ZegoCallTheme>();
    final theme = ZegoCallTheme.resolve(themeExt, colorScheme, textTheme);

    final hasSlots = leadingBuilder != null || trailingBuilder != null;

    final centerControls = Row(
      mainAxisSize: MainAxisSize.min,
      children: _buildCenterControls(theme),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: theme.controlsBarColor,
      child: hasSlots
          ? Row(
              children: [
                if (leadingBuilder != null)
                  Expanded(child: leadingBuilder!(context)),
                centerControls,
                if (trailingBuilder != null)
                  Expanded(child: trailingBuilder!(context)),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [centerControls],
            ),
    );
  }

  List<Widget> _buildCenterControls(ZegoCallTheme theme) {
    final controls = <Widget>[];

    if (config.showMicrophoneToggle) {
      controls.add(ZegoControlPill(
        icon: Icons.mic,
        offIcon: Icons.mic_off,
        isOn: isMicOn,
        onToggle: onToggleMic,
        devices: microphones,
        selectedDeviceId: selectedMicrophoneId,
        onDeviceSelected: onMicrophoneSelected ?? (_) {},
        onChevronTap: onMicChevron,
        pillColor: theme.controlPillColor!,
        mutedPillColor: theme.controlPillMutedColor!,
        iconColor: theme.activeControlColor!,
        mutedIconColor: theme.controlMutedIconColor!,
      ));
    }

    if (config.showCameraToggle) {
      controls.add(ZegoControlPill(
        icon: Icons.videocam,
        offIcon: Icons.videocam_off,
        isOn: isCameraOn,
        onToggle: onToggleCamera,
        devices: cameras,
        selectedDeviceId: selectedCameraId,
        onDeviceSelected: onCameraSelected ?? (_) {},
        onChevronTap: onCameraChevron,
        pillColor: theme.controlPillColor!,
        mutedPillColor: theme.controlPillMutedColor!,
        iconColor: theme.activeControlColor!,
        mutedIconColor: theme.controlMutedIconColor!,
      ));
    }

    if (config.showScreenShareButton) {
      controls.add(ZegoControlCircle(
        icon: isScreenSharing ? Icons.stop_screen_share : Icons.screen_share,
        color: isScreenSharing
            ? theme.controlMutedIconColor!
            : theme.activeControlColor!,
        backgroundColor: isScreenSharing
            ? theme.controlPillMutedColor!
            : theme.controlCircleColor!,
        onPressed: onToggleScreenShare,
      ));
    }

    if (config.showLayoutSwitcher) {
      controls.add(ZegoControlCircle(
        icon: Icons.grid_view,
        color: theme.activeControlColor!,
        backgroundColor: theme.controlCircleColor!,
        onPressed: onLayoutSwitcher,
      ));
    }

    controls.add(ZegoHangUpButton(
      onPressed: onHangUp,
      backgroundColor: theme.hangUpColor,
    ));

    // Intersperse with 8px gaps.
    final spaced = <Widget>[];
    for (var i = 0; i < controls.length; i++) {
      spaced.add(controls[i]);
      if (i < controls.length - 1) {
        spaced.add(const SizedBox(width: 8));
      }
    }
    return spaced;
  }
}
