import 'package:flutter/material.dart';
import 'package:zegoweb/src/models/zego_device_info.dart';

import 'package:zegoweb_ui/src/models/zego_audio_settings.dart';
import 'package:zegoweb_ui/src/zego_call_config.dart';
import 'package:zegoweb_ui/src/zego_call_theme.dart';
import 'package:zegoweb_ui/src/widgets/zego_audio_settings_popover.dart';
import 'package:zegoweb_ui/src/widgets/zego_control_circle.dart';
import 'package:zegoweb_ui/src/widgets/zego_control_pill.dart';
import 'package:zegoweb_ui/src/widgets/zego_hang_up_button.dart';

class ZegoControlsBar extends StatefulWidget {
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
    required this.audioSettings,
    this.onCameraSelected,
    this.onMicrophoneSelected,
    this.onMicChevron,
    this.onCameraChevron,
    this.onSettingsChanged,
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
  final ZegoAudioSettings audioSettings;
  final ValueChanged<ZegoDeviceInfo>? onCameraSelected;
  final ValueChanged<ZegoDeviceInfo>? onMicrophoneSelected;
  final VoidCallback? onMicChevron;
  final VoidCallback? onCameraChevron;
  final ValueChanged<ZegoAudioSettings>? onSettingsChanged;
  final WidgetBuilder? leadingBuilder;
  final WidgetBuilder? trailingBuilder;

  @override
  State<ZegoControlsBar> createState() => _ZegoControlsBarState();
}

class _ZegoControlsBarState extends State<ZegoControlsBar> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _settingsOverlay;

  @override
  void didUpdateWidget(ZegoControlsBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When the controller pushes new settings, rebuild the open popover.
    if (oldWidget.audioSettings != widget.audioSettings) {
      _settingsOverlay?.markNeedsBuild();
    }
  }

  @override
  void dispose() {
    _closeSettings();
    super.dispose();
  }

  void _toggleSettings() {
    if (_settingsOverlay != null) {
      _closeSettings();
    } else {
      _openSettings();
    }
  }

  void _openSettings() {
    _settingsOverlay = OverlayEntry(
      builder: (_) => ZegoAudioSettingsPopover(
        link: _layerLink,
        settings: widget.audioSettings,
        onChanged: (s) {
          widget.onSettingsChanged?.call(s);
          _settingsOverlay?.markNeedsBuild();
        },
        onDismiss: _closeSettings,
      ),
    );
    Overlay.of(context).insert(_settingsOverlay!);
    setState(() {});
  }

  void _closeSettings() {
    final overlay = _settingsOverlay;
    _settingsOverlay = null;
    overlay?.remove();
    overlay?.dispose(); // required since Flutter 3.22 to release OverlayEntry resources
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final themeExt = Theme.of(context).extension<ZegoCallTheme>();
    final theme = ZegoCallTheme.resolve(themeExt, colorScheme, textTheme);

    final hasSlots =
        widget.leadingBuilder != null || widget.trailingBuilder != null;

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
                if (widget.leadingBuilder != null)
                  Expanded(child: widget.leadingBuilder!(context)),
                centerControls,
                if (widget.trailingBuilder != null)
                  Expanded(child: widget.trailingBuilder!(context)),
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

    if (widget.config.showMicrophoneToggle) {
      controls.add(ZegoControlPill(
        icon: Icons.mic,
        offIcon: Icons.mic_off,
        isOn: widget.isMicOn,
        onToggle: widget.onToggleMic,
        devices: widget.microphones,
        selectedDeviceId: widget.selectedMicrophoneId,
        onDeviceSelected: widget.onMicrophoneSelected ?? (_) {},
        onChevronTap: widget.onMicChevron,
        pillColor: theme.controlPillColor!,
        mutedPillColor: theme.controlPillMutedColor!,
        iconColor: theme.activeControlColor!,
        mutedIconColor: theme.controlMutedIconColor!,
      ));
    }

    if (widget.config.showCameraToggle) {
      controls.add(ZegoControlPill(
        icon: Icons.videocam,
        offIcon: Icons.videocam_off,
        isOn: widget.isCameraOn,
        onToggle: widget.onToggleCamera,
        devices: widget.cameras,
        selectedDeviceId: widget.selectedCameraId,
        onDeviceSelected: widget.onCameraSelected ?? (_) {},
        onChevronTap: widget.onCameraChevron,
        pillColor: theme.controlPillColor!,
        mutedPillColor: theme.controlPillMutedColor!,
        iconColor: theme.activeControlColor!,
        mutedIconColor: theme.controlMutedIconColor!,
      ));
    }

    if (widget.config.showScreenShareButton) {
      controls.add(ZegoControlCircle(
        icon: widget.isScreenSharing
            ? Icons.stop_screen_share
            : Icons.screen_share,
        color: widget.isScreenSharing
            ? theme.controlMutedIconColor!
            : theme.activeControlColor!,
        backgroundColor: widget.isScreenSharing
            ? theme.controlPillMutedColor!
            : theme.controlCircleColor!,
        onPressed: widget.onToggleScreenShare,
      ));
    }

    if (widget.config.showLayoutSwitcher) {
      controls.add(ZegoControlCircle(
        icon: Icons.grid_view,
        color: theme.activeControlColor!,
        backgroundColor: theme.controlCircleColor!,
        onPressed: widget.onLayoutSwitcher,
      ));
    }

    controls.add(ZegoHangUpButton(
      onPressed: widget.onHangUp,
      backgroundColor: theme.hangUpColor,
    ));

    // Gear / settings button — wraps CompositedTransformTarget so the popover
    // can anchor itself above the button via the shared LayerLink.
    controls.add(
      CompositedTransformTarget(
        link: _layerLink,
        child: ZegoControlCircle(
          icon: Icons.settings,
          color: _settingsOverlay != null
              ? theme.controlPillColor!
              : theme.activeControlColor!,
          backgroundColor: _settingsOverlay != null
              ? (theme.activeControlColor ?? Colors.white).withValues(alpha: 0.15)
              : theme.controlCircleColor!,
          onPressed: _toggleSettings,
        ),
      ),
    );

    // Intersperse with 8 px gaps.
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
