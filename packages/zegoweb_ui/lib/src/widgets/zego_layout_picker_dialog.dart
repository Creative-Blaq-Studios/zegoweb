import 'package:flutter/material.dart';
import 'package:zegoweb_ui/src/zego_call_theme.dart';
import 'package:zegoweb_ui/src/zego_layout_mode.dart';

/// A Google Meet-style "Adjust view" dialog for selecting a call layout.
///
/// Stateless — all mutable state is owned by the caller via callbacks.
class ZegoLayoutPickerDialog extends StatelessWidget {
  const ZegoLayoutPickerDialog({
    super.key,
    required this.currentLayout,
    required this.hideNoVideoTiles,
    required this.onLayoutSelected,
    required this.onHideNoVideoTilesChanged,
    required this.onClose,
    this.gridColumns,
    this.onGridColumnsChanged,
  });

  final ZegoLayoutMode currentLayout;
  final bool hideNoVideoTiles;
  final ValueChanged<ZegoLayoutMode> onLayoutSelected;
  final ValueChanged<bool> onHideNoVideoTilesChanged;
  final VoidCallback onClose;
  final int? gridColumns;
  final ValueChanged<int?>? onGridColumnsChanged;

  static const _layouts = <(ZegoLayoutMode, String, IconData)>[
    (ZegoLayoutMode.grid, 'Grid', Icons.grid_view),
    (ZegoLayoutMode.sidebar, 'Sidebar', Icons.view_sidebar),
    (ZegoLayoutMode.pip, 'Picture-in-picture', Icons.picture_in_picture),
    (ZegoLayoutMode.spotlight, 'Spotlight', Icons.person),
    (ZegoLayoutMode.gallery, 'Gallery', Icons.view_comfy),
    (ZegoLayoutMode.auto, 'Auto', Icons.auto_awesome),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = ZegoCallTheme.resolve(
      Theme.of(context).extension<ZegoCallTheme>(),
      colorScheme,
      Theme.of(context).textTheme,
    );

    final bgColor = theme.controlsBarColor ?? const Color(0xFF2D2E31);
    final activeColor = theme.activeControlColor ?? Colors.white;
    final inactiveColor = theme.inactiveControlColor ?? const Color(0xFF9AA0A6);

    final sliderEnabled = currentLayout == ZegoLayoutMode.grid ||
        currentLayout == ZegoLayoutMode.auto;
    final columns = gridColumns?.toDouble() ?? 4.0;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 340,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x99000000),
              blurRadius: 32,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DialogHeader(
              activeColor: activeColor,
              onClose: onClose,
            ),
            ...ZegoLayoutPickerDialog._layouts.map(
              (entry) => _LayoutOption(
                mode: entry.$1,
                label: entry.$2,
                icon: entry.$3,
                isSelected: currentLayout == entry.$1,
                activeColor: colorScheme.primary,
                textColor: currentLayout == entry.$1 ? activeColor : inactiveColor,
                onTap: () => onLayoutSelected(entry.$1),
              ),
            ),
            const SizedBox(height: 4),
            Divider(
              height: 1,
              thickness: 1,
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              indent: 16,
              endIndent: 16,
            ),
            const SizedBox(height: 8),
            _SectionHeader(label: 'Tiles', color: inactiveColor),
            _TileSizeSlider(
              columns: columns,
              enabled: sliderEnabled,
              activeColor: colorScheme.primary,
              inactiveColor: inactiveColor,
              onChanged: sliderEnabled
                  ? (v) => onGridColumnsChanged?.call(v.round())
                  : null,
            ),
            _HideVideolessTilesRow(
              value: hideNoVideoTiles,
              activeColor: activeColor,
              colorScheme: colorScheme,
              onChanged: onHideNoVideoTilesChanged,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private widgets
// ---------------------------------------------------------------------------

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({
    required this.activeColor,
    required this.onClose,
  });

  final Color activeColor;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Adjust view',
              style: TextStyle(
                color: activeColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            iconSize: 18,
            color: activeColor,
            onPressed: onClose,
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _LayoutOption extends StatelessWidget {
  const _LayoutOption({
    required this.mode,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.activeColor,
    required this.textColor,
    required this.onTap,
  });

  final ZegoLayoutMode mode;
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color activeColor;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            _RadioCircle(isSelected: isSelected, activeColor: activeColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
            Icon(icon, size: 18, color: textColor),
          ],
        ),
      ),
    );
  }
}

class _RadioCircle extends StatelessWidget {
  const _RadioCircle({
    required this.isSelected,
    required this.activeColor,
  });

  final bool isSelected;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? activeColor : const Color(0xFF9AA0A6),
          width: 2,
        ),
        color: isSelected ? activeColor : Colors.transparent,
      ),
      child: isSelected
          ? const Center(
              child: Icon(Icons.circle, size: 8, color: Colors.white),
            )
          : null,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _TileSizeSlider extends StatelessWidget {
  const _TileSizeSlider({
    required this.columns,
    required this.enabled,
    required this.activeColor,
    required this.inactiveColor,
    required this.onChanged,
  });

  final double columns;
  final bool enabled;
  final Color activeColor;
  final Color inactiveColor;
  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Slider(
        value: columns.clamp(2.0, 6.0),
        min: 2,
        max: 6,
        divisions: 4,
        activeColor: enabled ? activeColor : inactiveColor,
        inactiveColor: inactiveColor.withValues(alpha: 0.3),
        onChanged: enabled ? onChanged : null,
      ),
    );
  }
}

class _HideVideolessTilesRow extends StatelessWidget {
  const _HideVideolessTilesRow({
    required this.value,
    required this.activeColor,
    required this.colorScheme,
    required this.onChanged,
  });

  final bool value;
  final Color activeColor;
  final ColorScheme colorScheme;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Hide tiles without video',
              style: TextStyle(color: activeColor, fontSize: 13),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: colorScheme.primary,
            activeTrackColor: colorScheme.primaryContainer,
            inactiveThumbColor: colorScheme.outline,
            inactiveTrackColor: colorScheme.surfaceContainerHighest,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}
