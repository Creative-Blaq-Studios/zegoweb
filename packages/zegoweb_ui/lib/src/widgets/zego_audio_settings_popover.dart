import 'package:flutter/material.dart';
import 'package:zegoweb_ui/src/models/zego_audio_settings.dart';

/// An overlay popover anchored above the gear button that exposes
/// AEC / ANS / AGC toggle switches.
///
/// Instantiate via [ZegoControlsBar] which owns the [LayerLink] and
/// [OverlayEntry] lifecycle.
class ZegoAudioSettingsPopover extends StatefulWidget {
  const ZegoAudioSettingsPopover({
    super.key,
    required this.link,
    required this.settings,
    required this.onChanged,
    required this.onDismiss,
  });

  /// The [LayerLink] attached to the gear button via [CompositedTransformTarget].
  final LayerLink link;

  /// Current audio settings shown in the popover.
  final ZegoAudioSettings settings;

  /// Called immediately when a toggle changes.
  final ValueChanged<ZegoAudioSettings> onChanged;

  /// Called when the user taps outside the popover.
  final VoidCallback onDismiss;

  @override
  State<ZegoAudioSettingsPopover> createState() =>
      _ZegoAudioSettingsPopoverState();
}

class _ZegoAudioSettingsPopoverState extends State<ZegoAudioSettingsPopover> {
  late ZegoAudioSettings _local;

  @override
  void initState() {
    super.initState();
    _local = widget.settings;
  }

  @override
  void didUpdateWidget(ZegoAudioSettingsPopover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings != widget.settings) {
      setState(() => _local = widget.settings);
    }
  }

  void _toggle(ZegoAudioSettings updated) {
    setState(() => _local = updated);
    widget.onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Full-screen tap-to-dismiss area.
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onDismiss,
            behavior: HitTestBehavior.opaque,
            child: const SizedBox.expand(),
          ),
        ),
        // Popover anchored above the gear button.
        CompositedTransformFollower(
          link: widget.link,
          targetAnchor: Alignment.topCenter,
          followerAnchor: Alignment.bottomCenter,
          offset: const Offset(0, -8),
          child: Align(
            alignment: Alignment.topLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PopoverCard(local: _local, onToggle: _toggle),
                const _PopoverArrow(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Private widgets
// ---------------------------------------------------------------------------

class _PopoverCard extends StatelessWidget {
  const _PopoverCard({required this.local, required this.onToggle});

  final ZegoAudioSettings local;
  final ValueChanged<ZegoAudioSettings> onToggle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 220,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: const Color(0xFF242424),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF383838)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x99000000),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Audio Settings',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 10),
            _SettingsRow(
              label: 'Echo Cancellation',
              subtitle: 'Prevents feedback',
              value: local.echoCancellation,
              onChanged: (v) => onToggle(local.copyWith(echoCancellation: v)),
            ),
            _SettingsRow(
              label: 'Noise Suppression',
              subtitle: 'Filters background noise',
              value: local.noiseSuppression,
              onChanged: (v) => onToggle(local.copyWith(noiseSuppression: v)),
            ),
            _SettingsRow(
              label: 'Auto Gain Control',
              subtitle: 'Levels mic volume',
              value: local.autoGainControl,
              onChanged: (v) => onToggle(local.copyWith(autoGainControl: v)),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Triangle indicator (points downward toward the gear button)
// ---------------------------------------------------------------------------

class _PopoverArrow extends StatelessWidget {
  const _PopoverArrow();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(8, 8),
      painter: _DownTrianglePainter(),
    );
  }
}

class _DownTrianglePainter extends CustomPainter {
  const _DownTrianglePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = const Color(0xFF242424)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = const Color(0xFF383838)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final fillPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    // Stroke only the two diagonal sides — not the top edge — so there is no
    // visible seam between the card border and the triangle.
    final strokePath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0);

    canvas.drawPath(fillPath, fill);
    canvas.drawPath(strokePath, stroke);
  }

  @override
  bool shouldRepaint(_DownTrianglePainter old) => false;
}

// ---------------------------------------------------------------------------

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF4CAF50),
            activeTrackColor: const Color(0xFF2E7D32),
            inactiveThumbColor: const Color(0xFF888888),
            inactiveTrackColor: const Color(0xFF383838),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}
