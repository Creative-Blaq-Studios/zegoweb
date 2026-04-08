// packages/zegoweb/lib/src/zego_video_view.dart
import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

import 'video_view_registry.dart';
import 'zego_local_stream.dart';
import 'zego_remote_stream.dart';

/// Renders a local or remote Zego stream into the Flutter tree via
/// [HtmlElementView].
class ZegoVideoView extends StatefulWidget {
  const ZegoVideoView({
    super.key,
    required this.stream,
    this.fit = BoxFit.cover,
    this.mirror = false,
  });

  /// Must be a `ZegoLocalStream` or `ZegoRemoteStream`.
  final Object stream;
  final BoxFit fit;
  final bool mirror;

  @override
  State<ZegoVideoView> createState() => ZegoVideoViewState();
}

class ZegoVideoViewState extends State<ZegoVideoView> {
  late String _viewType;

  @visibleForTesting
  String get debugViewType => _viewType;

  @override
  void initState() {
    super.initState();
    if (widget.stream is! ZegoLocalStream &&
        widget.stream is! ZegoRemoteStream) {
      throw ArgumentError.value(
        widget.stream,
        'stream',
        'Expected ZegoLocalStream or ZegoRemoteStream',
      );
    }
    _viewType = VideoViewRegistry.instance.registerStream(widget.stream);
    _applyStyles();
  }

  @override
  void didUpdateWidget(covariant ZegoVideoView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.stream, widget.stream)) {
      VideoViewRegistry.instance.unregisterStream(_viewType);
      _viewType = VideoViewRegistry.instance.registerStream(widget.stream);
    }
    _applyStyles();
  }

  void _applyStyles() {
    final element = VideoViewRegistry.instance.elementFor(_viewType);
    if (element == null) return;
    _applyFit(element, widget.fit);
    element.style.transform = widget.mirror ? 'scaleX(-1)' : 'none';
  }

  void _applyFit(web.HTMLVideoElement element, BoxFit fit) {
    switch (fit) {
      case BoxFit.cover:
        element.style.objectFit = 'cover';
        break;
      case BoxFit.contain:
        element.style.objectFit = 'contain';
        break;
      case BoxFit.fill:
        element.style.objectFit = 'fill';
        break;
      case BoxFit.fitWidth:
      case BoxFit.fitHeight:
      case BoxFit.none:
      case BoxFit.scaleDown:
        element.style.objectFit = 'contain';
        break;
    }
  }

  @override
  void dispose() {
    VideoViewRegistry.instance.unregisterStream(_viewType);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }
}
