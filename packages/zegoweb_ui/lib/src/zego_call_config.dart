import 'package:meta/meta.dart';
import 'package:zegoweb_ui/src/zego_layout_mode.dart';

@immutable
class ZegoCallConfig {
  const ZegoCallConfig({
    required this.roomId,
    required this.userId,
    this.userName,
    this.layout = ZegoLayoutMode.grid,
    this.showPreJoinView = true,
    this.showMicrophoneToggle = true,
    this.showCameraToggle = true,
    this.showScreenShareButton = false,
    this.showLayoutSwitcher = true,
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
}
