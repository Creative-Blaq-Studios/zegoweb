import 'package:flutter/material.dart';
import 'package:zegoweb/zegoweb.dart';
import 'package:zegoweb_ui/src/zego_call_theme.dart';

/// Google Meet-style pre-join screen.
///
/// Layout: preview card (left) with overlaid mic/camera toggles and
/// compact device chip dropdowns below; join panel (right) with room
/// name and "Join now" button.
class ZegoPreJoinView extends StatefulWidget {
  const ZegoPreJoinView({
    super.key,
    required this.userName,
    required this.onJoin,
    this.roomName,
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
  final String? roomName;
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
    if (_selectedCameraId == null && widget.cameras.isNotEmpty) {
      _selectedCameraId = widget.cameras.first.deviceId;
    }
    if (_selectedMicId == null && widget.microphones.isNotEmpty) {
      _selectedMicId = widget.microphones.first.deviceId;
    }
  }

  String _deviceLabel(List<ZegoDeviceInfo> devices, String? selectedId) {
    if (devices.isEmpty) return '...';
    final device = devices.firstWhere(
      (d) => d.deviceId == selectedId,
      orElse: () => devices.first,
    );
    final name = device.deviceName;
    return name.length > 18 ? '${name.substring(0, 16)}...' : name;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final themeExt = Theme.of(context).extension<ZegoCallTheme>();
    final theme = ZegoCallTheme.resolve(themeExt, colorScheme, textTheme);

    return Container(
      color: theme.backgroundColor,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960, maxHeight: 560),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                // ---- Left: Preview card + device chips ----
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      // Preview card — 16:9 aspect ratio
                      Expanded(
                        child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            theme.tileBorderRadius ?? 12.0,
                          ),
                          child: Container(
                            color: const Color(0xFF0f0f1a),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // Video preview or camera-off placeholder
                                if (widget.isCameraOn &&
                                    widget.previewWidget != null)
                                  widget.previewWidget!
                                else
                                  Center(
                                    child: _Avatar(
                                      name: widget.userName,
                                      colorScheme: colorScheme,
                                    ),
                                  ),

                                // User name — top left
                                Positioned(
                                  top: 12,
                                  left: 14,
                                  child: Text(
                                    widget.userName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),

                                // Mic + Camera toggles — bottom center
                                Positioned(
                                  bottom: 14,
                                  left: 0,
                                  right: 0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _ToggleCircle(
                                        icon: widget.isMicOn
                                            ? Icons.mic
                                            : Icons.mic_off,
                                        isOn: widget.isMicOn,
                                        onTap: widget.onToggleMic,
                                      ),
                                      const SizedBox(width: 12),
                                      _ToggleCircle(
                                        icon: widget.isCameraOn
                                            ? Icons.videocam
                                            : Icons.videocam_off,
                                        isOn: widget.isCameraOn,
                                        onTap: widget.onToggleCamera,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      ),

                      const SizedBox(height: 12),

                      // Device chip dropdowns
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _DeviceChip(
                            icon: Icons.mic,
                            label: _deviceLabel(
                                widget.microphones, _selectedMicId),
                            devices: widget.microphones,
                            selectedId: _selectedMicId,
                            onSelected: (id) {
                              setState(() => _selectedMicId = id);
                              widget.onMicrophoneSelected?.call(id);
                            },
                          ),
                          const SizedBox(width: 8),
                          _DeviceChip(
                            icon: Icons.videocam,
                            label: _deviceLabel(
                                widget.cameras, _selectedCameraId),
                            devices: widget.cameras,
                            selectedId: _selectedCameraId,
                            onSelected: (id) {
                              setState(() => _selectedCameraId = id);
                              widget.onCameraSelected?.call(id);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 32),

                // ---- Right: Join panel ----
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Ready to join?',
                        style: textTheme.headlineSmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (widget.roomName != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          widget.roomName!,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      if (widget.isLoading)
                        const CircularProgressIndicator()
                      else
                        FilledButton(
                          onPressed: widget.onJoin,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text(
                            'Join now',
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private widgets
// ---------------------------------------------------------------------------

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, required this.colorScheme});
  final String name;
  final ColorScheme colorScheme;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 48,
      backgroundColor: colorScheme.primaryContainer,
      child: Text(
        _initials,
        style: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w600,
          color: colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class _ToggleCircle extends StatelessWidget {
  const _ToggleCircle({
    required this.icon,
    required this.isOn,
    required this.onTap,
  });

  final IconData icon;
  final bool isOn;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isOn
          ? Colors.white.withValues(alpha: 0.15)
          : Colors.red.withValues(alpha: 0.8),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

class _DeviceChip extends StatelessWidget {
  const _DeviceChip({
    required this.icon,
    required this.label,
    required this.devices,
    required this.selectedId,
    required this.onSelected,
  });

  final IconData icon;
  final String label;
  final List<ZegoDeviceInfo> devices;
  final String? selectedId;
  final void Function(String deviceId) onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      initialValue: selectedId,
      color: const Color(0xFF2a2a4a),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (_) => devices
          .map((d) => PopupMenuItem<String>(
                value: d.deviceId,
                child: Row(
                  children: [
                    if (d.deviceId == selectedId)
                      const Icon(Icons.check, size: 16, color: Colors.white70)
                    else
                      const SizedBox(width: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        d.deviceName,
                        style: TextStyle(
                          color: d.deviceId == selectedId
                              ? Colors.white
                              : Colors.white70,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF2a2a4a),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.white70),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 16, color: Colors.white54),
          ],
        ),
      ),
    );
  }
}
