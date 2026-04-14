import 'package:flutter/painting.dart';
import 'package:meta/meta.dart';
import 'package:zegoweb_ui/src/zego_layout_mode.dart';

@immutable
class ZegoCallConfig {
  const ZegoCallConfig({
    required this.roomId,
    required this.userId,
    this.userName,
    this.layout = ZegoLayoutMode.grid,
    this.videoFit = BoxFit.contain,
    this.showPreJoinView = true,
    this.showMicrophoneToggle = true,
    this.showCameraToggle = true,
    this.showScreenShareButton = false,
    this.showLayoutSwitcher = true,
    this.showAudioDebugOverlay = false,
  });

  final String roomId;
  final String userId;
  final String? userName;
  final ZegoLayoutMode layout;
  final bool showPreJoinView;
  final bool showMicrophoneToggle;
  final bool showCameraToggle;
  final bool showScreenShareButton;
  final bool showLayoutSwitcher;

  /// How remote and local video streams are fitted within their tile.
  /// Defaults to [BoxFit.contain] (preserves aspect ratio, letterboxes).
  final BoxFit videoFit;

  /// When true, a floating audio debug overlay is shown in the call screen.
  /// The overlay shows live mic levels, active-speaker state, and controls
  /// for adjusting the detection threshold and debounce at runtime.
  final bool showAudioDebugOverlay;
}
