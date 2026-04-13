import 'package:flutter/material.dart';
import 'package:zegoweb/src/models/zego_device_info.dart';

import 'package:zegoweb_ui/src/widgets/zego_device_popover.dart';

class ZegoControlPill extends StatefulWidget {
  const ZegoControlPill({
    super.key,
    required this.icon,
    required this.offIcon,
    required this.isOn,
    required this.onToggle,
    required this.devices,
    required this.selectedDeviceId,
    required this.onDeviceSelected,
    this.onChevronTap,
    required this.pillColor,
    required this.mutedPillColor,
    required this.iconColor,
    required this.mutedIconColor,
  });

  final IconData icon;
  final IconData offIcon;
  final bool isOn;
  final VoidCallback onToggle;
  final List<ZegoDeviceInfo> devices;
  final String selectedDeviceId;
  final ValueChanged<ZegoDeviceInfo> onDeviceSelected;
  final VoidCallback? onChevronTap;
  final Color pillColor;
  final Color mutedPillColor;
  final Color iconColor;
  final Color mutedIconColor;

  @override
  State<ZegoControlPill> createState() => _ZegoControlPillState();
}

class _ZegoControlPillState extends State<ZegoControlPill> {
  final _chevronKey = GlobalKey();
  bool _popoverOpen = false;

  void _onChevronTap() {
    if (widget.onChevronTap != null) {
      widget.onChevronTap!();
      return;
    }
    _showDevicePopover();
  }

  void _showDevicePopover() {
    final renderBox =
        _chevronKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    setState(() => _popoverOpen = true);

    showDialog<ZegoDeviceInfo>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (dialogContext) {
        final position = renderBox.localToGlobal(Offset.zero);
        final screenSize = MediaQuery.of(dialogContext).size;
        // Position popover so its bottom sits above the pill with 8px gap.
        final bottomOffset = screenSize.height - position.dy + 8;

        return Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(dialogContext).pop(),
              behavior: HitTestBehavior.opaque,
              child: const SizedBox.expand(),
            ),
            Positioned(
              left: position.dx,
              bottom: bottomOffset,
              child: Material(
                color: Colors.transparent,
                child: ZegoDevicePopover(
                  devices: widget.devices,
                  selectedDeviceId: widget.selectedDeviceId,
                  onDeviceSelected: (device) {
                    widget.onDeviceSelected(device);
                    Navigator.of(dialogContext).pop(device);
                  },
                ),
              ),
            ),
          ],
        );
      },
    ).then((_) {
      if (mounted) setState(() => _popoverOpen = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isOn ? widget.pillColor : widget.mutedPillColor;
    final fgColor = widget.isOn ? widget.iconColor : widget.mutedIconColor;
    final dividerColor = fgColor.withValues(alpha: 0.3);
    final currentIcon = widget.isOn ? widget.icon : widget.offIcon;
    final chevronIcon = _popoverOpen ? Icons.expand_more : Icons.expand_less;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Chevron side
          GestureDetector(
            key: _chevronKey,
            onTap: _onChevronTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 10,
                top: 10,
                bottom: 10,
                right: 4,
              ),
              child: Icon(chevronIcon, size: 16, color: fgColor),
            ),
          ),
          // Divider
          SizedBox(
            height: 20,
            child: VerticalDivider(
              width: 1,
              thickness: 1,
              color: dividerColor,
            ),
          ),
          // Toggle icon side
          GestureDetector(
            onTap: widget.onToggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 8,
                top: 10,
                bottom: 10,
                right: 10,
              ),
              child: Icon(currentIcon, size: 20, color: fgColor),
            ),
          ),
        ],
      ),
    );
  }
}
