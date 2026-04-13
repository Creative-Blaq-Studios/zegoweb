import 'package:flutter/material.dart';

class ZegoControlCircle extends StatelessWidget {
  const ZegoControlCircle({
    super.key,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.onPressed,
    this.size = 40.0,
  });

  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon),
          color: color,
          padding: EdgeInsets.zero,
          constraints: BoxConstraints.tightFor(width: size, height: size),
          style: IconButton.styleFrom(
            shape: const CircleBorder(),
          ),
        ),
      ),
    );
  }
}
