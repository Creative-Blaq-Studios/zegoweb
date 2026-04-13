import 'package:flutter/material.dart';
import 'package:zegoweb/zegoweb.dart';
import 'package:zegoweb_ui/src/zego_call_theme.dart';

/// A pre-join setup screen with live camera preview, mic/camera toggles,
/// and device selection dropdowns.
///
/// The user configures their audio/video settings here before entering the
/// call. Settings chosen here are carried into the call.
class ZegoPreJoinView extends StatefulWidget {
  const ZegoPreJoinView({
    super.key,
    required this.userName,
    required this.onJoin,
    this.previewWidget,
    this.isLoading = false,
    this.isMicOn = true,
    this.isCameraOn = true,
    this.onToggleMic,
    this.onToggleCamera,
    this.cameras = const [],
    this.microphones = const [],
    this.onCameraSelected,
    this.onMicrophoneSelected,
  });

  final String userName;
  final VoidCallback onJoin;
  final Widget? previewWidget;
  final bool isLoading;
  final bool isMicOn;
  final bool isCameraOn;
  final VoidCallback? onToggleMic;
  final VoidCallback? onToggleCamera;
  final List<ZegoDeviceInfo> cameras;
  final List<ZegoDeviceInfo> microphones;
  final void Function(String deviceId)? onCameraSelected;
  final void Function(String deviceId)? onMicrophoneSelected;

  @override
  State<ZegoPreJoinView> createState() => _ZegoPreJoinViewState();
}

class _ZegoPreJoinViewState extends State<ZegoPreJoinView> {
  String? _selectedCameraId;
  String? _selectedMicId;

  @override
  void didUpdateWidget(covariant ZegoPreJoinView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Auto-select first device if list just populated
    if (_selectedCameraId == null && widget.cameras.isNotEmpty) {
      _selectedCameraId = widget.cameras.first.deviceId;
    }
    if (_selectedMicId == null && widget.microphones.isNotEmpty) {
      _selectedMicId = widget.microphones.first.deviceId;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final themeExt = Theme.of(context).extension<ZegoCallTheme>();
    final theme = ZegoCallTheme.resolve(themeExt, colorScheme, textTheme);

    return Container(
      color: theme.backgroundColor,
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Left side: camera preview
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(theme.tileBorderRadius ?? 12.0),
              child: Container(
                color: theme.tileBackgroundColor,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (widget.isCameraOn && widget.previewWidget != null)
                      widget.previewWidget!
                    else
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.videocam_off,
                              size: 64,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Camera off',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Mic/camera toggle overlay at bottom
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _ToggleButton(
                            icon: widget.isMicOn ? Icons.mic : Icons.mic_off,
                            isOn: widget.isMicOn,
                            onTap: widget.onToggleMic,
                            theme: theme,
                          ),
                          const SizedBox(width: 16),
                          _ToggleButton(
                            icon: widget.isCameraOn
                                ? Icons.videocam
                                : Icons.videocam_off,
                            isOn: widget.isCameraOn,
                            onTap: widget.onToggleCamera,
                            theme: theme,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          // Right side: settings panel
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.userName,
                  style: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Camera picker
                if (widget.cameras.isNotEmpty) ...[
                  Text('Camera',
                      style: textTheme.labelMedium
                          ?.copyWith(color: colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCameraId,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: widget.cameras
                        .map((d) => DropdownMenuItem(
                              value: d.deviceId,
                              child: Text(d.deviceName,
                                  overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (id) {
                      if (id != null) {
                        setState(() => _selectedCameraId = id);
                        widget.onCameraSelected?.call(id);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                // Microphone picker
                if (widget.microphones.isNotEmpty) ...[
                  Text('Microphone',
                      style: textTheme.labelMedium
                          ?.copyWith(color: colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedMicId,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: widget.microphones
                        .map((d) => DropdownMenuItem(
                              value: d.deviceId,
                              child: Text(d.deviceName,
                                  overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (id) {
                      if (id != null) {
                        setState(() => _selectedMicId = id);
                        widget.onMicrophoneSelected?.call(id);
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                ],
                // Join button
                if (widget.isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  FilledButton.icon(
                    onPressed: widget.onJoin,
                    icon: const Icon(Icons.videocam),
                    label: const Text('Join Call'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.icon,
    required this.isOn,
    required this.onTap,
    required this.theme,
  });

  final IconData icon;
  final bool isOn;
  final VoidCallback? onTap;
  final ZegoCallTheme theme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isOn ? Colors.white24 : Colors.red.withValues(alpha: 0.7),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}
