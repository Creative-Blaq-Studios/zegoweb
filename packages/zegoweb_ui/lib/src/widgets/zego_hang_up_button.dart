import 'package:flutter/material.dart';

class ZegoHangUpButton extends StatelessWidget {
  const ZegoHangUpButton({
    super.key,
    required this.onPressed,
    this.backgroundColor,
    this.iconColor,
  });

  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Theme.of(context).colorScheme.error;

    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.call_end),
      color: iconColor ?? Colors.white,
      style: IconButton.styleFrom(
        backgroundColor: bgColor,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
      ),
    );
  }
}
