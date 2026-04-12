import 'package:flutter/material.dart';
import 'package:zegoweb_ui/src/widgets/zego_participant_tile.dart';
import 'package:zegoweb_ui/src/zego_participant.dart';

/// A picture-in-picture layout with a full-screen participant and a
/// draggable floating overlay for a second participant.
///
/// The [fullScreenParticipant] fills the entire area. The
/// [floatingParticipant] appears as a small, repositionable tile
/// (default position: top-right corner).
class ZegoPipLayout extends StatefulWidget {
  const ZegoPipLayout({
    super.key,
    required this.fullScreenParticipant,
    required this.floatingParticipant,
    this.floatingWidth = 120,
    this.floatingHeight = 160,
    this.showName = true,
    this.showMicIndicator = true,
    this.videoViewBuilder,
  });

  /// The participant displayed in the full-screen background.
  final ZegoParticipant fullScreenParticipant;

  /// The participant displayed in the floating overlay.
  final ZegoParticipant floatingParticipant;

  /// Width of the floating overlay. Defaults to 120.
  final double floatingWidth;

  /// Height of the floating overlay. Defaults to 160.
  final double floatingHeight;

  /// Whether to show participant names on tiles.
  final bool showName;

  /// Whether to show mic indicators on tiles.
  final bool showMicIndicator;

  /// Optional builder for creating video view widgets from stream objects.
  final VideoViewBuilder? videoViewBuilder;

  @override
  State<ZegoPipLayout> createState() => _ZegoPipLayoutState();
}

class _ZegoPipLayoutState extends State<ZegoPipLayout> {
  double _top = 16;
  double _right = 16;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Full-screen participant.
        Positioned.fill(
          child: ZegoParticipantTile(
            participant: widget.fullScreenParticipant,
            showName: widget.showName,
            showMicIndicator: widget.showMicIndicator,
            mirror: widget.fullScreenParticipant.isLocal,
            videoViewBuilder: widget.videoViewBuilder,
          ),
        ),
        // Draggable floating overlay.
        Positioned(
          top: _top,
          right: _right,
          width: widget.floatingWidth,
          height: widget.floatingHeight,
          child: GestureDetector(
            onPanUpdate: _onPanUpdate,
            child: ZegoParticipantTile(
              participant: widget.floatingParticipant,
              showName: widget.showName,
              showMicIndicator: widget.showMicIndicator,
              mirror: widget.floatingParticipant.isLocal,
              videoViewBuilder: widget.videoViewBuilder,
            ),
          ),
        ),
      ],
    );
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _top += details.delta.dy;
      _right -= details.delta.dx;
    });
  }
}
