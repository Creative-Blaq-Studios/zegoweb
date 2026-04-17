import 'package:flutter/painting.dart';
import 'package:meta/meta.dart';
import 'package:zegoweb_ui/src/zego_layout_mode.dart';

@immutable
class ZegoCallConfig {
  const ZegoCallConfig({
    required this.roomId,
    required this.userId,
    this.userName,
    this.layout = ZegoLayoutMode.auto,
    this.videoFit = BoxFit.contain,
    this.showPreJoinView = true,
    this.showMicrophoneToggle = true,
    this.showCameraToggle = true,
    this.showScreenShareButton = false,
    this.showLayoutPicker = true,
    this.hideNoVideoTiles = false,
    this.showAudioDebugOverlay = false,
    this.streamIdBuilder,
  });

  final String roomId;
  final String userId;
  final String? userName;
  final ZegoLayoutMode layout;
  final BoxFit videoFit;
  final bool showPreJoinView;
  final bool showMicrophoneToggle;
  final bool showCameraToggle;
  final bool showScreenShareButton;
  final bool showLayoutPicker;
  final bool hideNoVideoTiles;

  /// When true, a floating audio debug overlay is shown in the call screen.
  /// The overlay shows live mic levels, active-speaker state, and controls
  /// for adjusting the detection threshold and debounce at runtime.
  final bool showAudioDebugOverlay;

  /// Builds the stream ID the local user publishes under. When `null`, the
  /// controller uses [defaultStreamIdBuilder], which matches the format the
  /// ZEGO mobile prebuilt UI kit uses (`{roomId}_{userId}_main`). Override
  /// this only if you need to interoperate with a kit that uses a different
  /// format.
  final String Function(String roomId, String userId)? streamIdBuilder;

  /// Default publish stream ID format: `{roomId}_{userId}_main`. Matches the
  /// ZEGO mobile prebuilt UI kit, so web and mobile peers can discover each
  /// other's streams when joining the same room.
  static String defaultStreamIdBuilder(String roomId, String userId) =>
      '${roomId}_${userId}_main';
}
