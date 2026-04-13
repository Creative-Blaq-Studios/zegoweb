import 'package:flutter/material.dart';
import 'package:zegoweb/src/models/zego_device_info.dart';
import 'package:zegoweb_ui/src/zego_call_theme.dart';

/// A popover that lists selectable devices (cameras or microphones).
///
/// Shows a checkmark next to the currently selected device and calls
/// [onDeviceSelected] when the user taps a different entry.
class ZegoDevicePopover extends StatelessWidget {
  const ZegoDevicePopover({
    super.key,
    required this.devices,
    required this.selectedDeviceId,
    required this.onDeviceSelected,
  });

  final List<ZegoDeviceInfo> devices;
  final String selectedDeviceId;
  final ValueChanged<ZegoDeviceInfo> onDeviceSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeExt = Theme.of(context).extension<ZegoCallTheme>();
    final theme = ZegoCallTheme.resolve(
      themeExt,
      colorScheme,
      Theme.of(context).textTheme,
    );

    if (devices.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.devicePopoverColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'No devices found',
          style: TextStyle(color: theme.inactiveControlColor, fontSize: 13),
        ),
      );
    }

    return IntrinsicWidth(
      child: Container(
      constraints: const BoxConstraints(minWidth: 220),
      decoration: BoxDecoration(
        color: theme.devicePopoverColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: devices.map((device) {
          final isSelected = device.deviceId == selectedDeviceId;
          return _DeviceItem(
            device: device,
            isSelected: isSelected,
            activeColor: colorScheme.primary,
            textColor: isSelected
                ? theme.activeControlColor!
                : theme.inactiveControlColor!,
            onTap: () => onDeviceSelected(device),
          );
        }).toList(),
      ),
    ),
    );
  }
}

class _DeviceItem extends StatelessWidget {
  const _DeviceItem({
    required this.device,
    required this.isSelected,
    required this.activeColor,
    required this.textColor,
    required this.onTap,
  });

  final ZegoDeviceInfo device;
  final bool isSelected;
  final Color activeColor;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.1) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              child: isSelected
                  ? Icon(Icons.check, size: 16, color: activeColor)
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              device.deviceName,
              style: TextStyle(color: textColor, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
