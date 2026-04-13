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
  final _gearKey = GlobalKey();
  bool _settingsOpen = false;

  void _toggleSettings() {
    if (_settingsOpen) return;
    final renderBox =
        _gearKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    setState(() => _settingsOpen = true);

    showDialog<void>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (dialogContext) {
        final position = renderBox.localToGlobal(Offset.zero);
        final screenSize = MediaQuery.of(dialogContext).size;
        // Position the popover so its bottom sits above the gear button.
        final bottomOffset = screenSize.height - position.dy + 8;
        // Center the popover horizontally over the gear button.
        final centerX = position.dx + renderBox.size.width / 2;

        return Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(dialogContext).pop(),
              behavior: HitTestBehavior.opaque,
              child: const SizedBox.expand(),
            ),
            Positioned(
              bottom: bottomOffset,
              left: centerX,
              child: FractionalTranslation(
                // Shift left by 50% of the popover's own width to center it.
                translation: const Offset(-0.5, 0),
                child: ZegoAudioSettingsPopover(
                  settings: widget.audioSettings,
                  onChanged: (s) => widget.onSettingsChanged?.call(s),
                ),
              ),
            ),
          ],
        );
      },
    ).then((_) {
      if (mounted) setState(() => _settingsOpen = false);
    });
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

    // Gear / settings button — GlobalKey lets _toggleSettings locate the
    // button's screen position for dialog placement.
    controls.add(
      ZegoControlCircle(
        key: _gearKey,
        icon: Icons.settings,
        color: _settingsOpen
            ? theme.controlPillColor!
            : theme.activeControlColor!,
        backgroundColor: _settingsOpen
            ? (theme.activeControlColor ?? Colors.white).withValues(alpha: 0.15)
            : theme.controlCircleColor!,
        onPressed: _toggleSettings,
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
