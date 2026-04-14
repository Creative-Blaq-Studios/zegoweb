import 'package:flutter/material.dart';
import 'package:zegoweb_ui/src/widgets/zego_participant_tile.dart';
import 'package:zegoweb_ui/src/zego_participant.dart';

/// A picture-in-picture layout with a full-screen participant and a
/// draggable floating overlay for a second participant.
///
/// The [fullScreenParticipant] fills the entire area. The
/// [floatingParticipant] appears as a small overlay that can be dragged
/// freely but always snaps to one of four corners (top-left, top-right,
/// bottom-left, bottom-right) when released. The tile is clamped to the
/// layout bounds at all times.
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
    this.isFullScreenActiveSpeaker = false,
    this.isFloatingActiveSpeaker = false,
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

  /// Whether the full-screen participant is the active speaker.
  final bool isFullScreenActiveSpeaker;

  /// Whether the floating participant is the active speaker.
  final bool isFloatingActiveSpeaker;

  @override
  State<ZegoPipLayout> createState() => _ZegoPipLayoutState();
}

class _ZegoPipLayoutState extends State<ZegoPipLayout> {
  static const double _edgePadding = 12.0;
  static const Duration _snapDuration = Duration(milliseconds: 260);
  static const Curve _snapCurve = Curves.easeOutCubic;

  // Left/top in the Stack's coordinate space; null until first layout.
  double? _left;
  double? _top;

  // Track the last known container size so we can re-clamp on resize.
  Size _containerSize = Size.zero;

  // True while the user is actively dragging — suppresses snap animation.
  bool _dragging = false;

  void _initOrClamp(Size size) {
    if (size == _containerSize && _left != null) return;
    _containerSize = size;
    if (_left == null) {
      // Default: top-right corner.
      _left = size.width - widget.floatingWidth - _edgePadding;
      _top = _edgePadding;
    } else {
      // Container resized — keep the tile on screen by re-snapping.
      _snapToNearestCorner(size, animate: false);
    }
  }

  void _snapToNearestCorner(Size size, {bool animate = true}) {
    final leftSnap = _edgePadding;
    final rightSnap = size.width - widget.floatingWidth - _edgePadding;
    final topSnap = _edgePadding;
    final bottomSnap = size.height - widget.floatingHeight - _edgePadding;

    final tileCenterX = (_left ?? leftSnap) + widget.floatingWidth / 2;
    final tileCenterY = (_top ?? topSnap) + widget.floatingHeight / 2;

    final targetLeft = tileCenterX < size.width / 2 ? leftSnap : rightSnap;
    final targetTop = tileCenterY < size.height / 2 ? topSnap : bottomSnap;

    if (animate) {
      setState(() {
        _left = targetLeft;
        _top = targetTop;
      });
    } else {
      _left = targetLeft;
      _top = targetTop;
    }
  }

  void _onPanStart(DragStartDetails _) {
    setState(() => _dragging = true);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final maxLeft = _containerSize.width - widget.floatingWidth - _edgePadding;
    final maxTop = _containerSize.height - widget.floatingHeight - _edgePadding;
    setState(() {
      _left = ((_left ?? 0) + details.delta.dx).clamp(_edgePadding, maxLeft);
      _top = ((_top ?? 0) + details.delta.dy).clamp(_edgePadding, maxTop);
    });
  }

  void _onPanEnd(DragEndDetails _) {
    setState(() => _dragging = false);
    _snapToNearestCorner(_containerSize);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        _initOrClamp(size);

        final left = _left!;
        final top = _top!;

        return Stack(
          children: [
            // Full-screen participant.
            Positioned.fill(
              child: ZegoParticipantTile(
                participant: widget.fullScreenParticipant,
                showName: widget.showName,
                showMicIndicator: widget.showMicIndicator,
                mirror: widget.fullScreenParticipant.isLocal,
                isActiveSpeaker: widget.isFullScreenActiveSpeaker,
                videoViewBuilder: widget.videoViewBuilder,
              ),
            ),
            // Draggable floating overlay — animated when snapping.
            AnimatedPositioned(
              duration: _dragging ? Duration.zero : _snapDuration,
              curve: _snapCurve,
              left: left,
              top: top,
              width: widget.floatingWidth,
              height: widget.floatingHeight,
              child: GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: ZegoParticipantTile(
                  participant: widget.floatingParticipant,
                  showName: widget.showName,
                  showMicIndicator: widget.showMicIndicator,
                  mirror: widget.floatingParticipant.isLocal,
                  isActiveSpeaker: widget.isFloatingActiveSpeaker,
                  videoViewBuilder: widget.videoViewBuilder,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
