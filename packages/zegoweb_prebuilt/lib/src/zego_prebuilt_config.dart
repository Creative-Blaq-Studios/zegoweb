import 'package:meta/meta.dart';

/// Scenario presets for the prebuilt UIKit.
enum ZegoPrebuiltScenario { oneOnOneCall, groupCall, videoConference }

/// Layout modes for the call grid.
enum ZegoPrebuiltLayout { auto, sidebar, grid }

/// Video resolution presets.
enum ZegoPrebuiltVideoResolution { sd180, sd360, sd480, hd720 }

/// Display language for the UIKit.
enum ZegoPrebuiltLanguage { english, chinese }

/// Configuration for a prebuilt UIKit call.
///
/// 17 typed fields cover the most common knobs. Every field has a sensible
/// default matching the UIKit's own defaults. A [rawConfig] escape hatch
/// forwards arbitrary key/value pairs to the JS `ZegoCloudRoomConfig`.
@immutable
class ZegoPrebuiltConfig {
  const ZegoPrebuiltConfig({
    required this.roomId,
    required this.userId,
    this.userName,
    this.scenario = ZegoPrebuiltScenario.oneOnOneCall,
    this.maxUsers,
    this.showPreJoinView = true,
    this.preJoinViewTitle,
    this.turnOnMicrophoneWhenJoining = true,
    this.turnOnCameraWhenJoining = true,
    this.useFrontFacingCamera = true,
    this.videoResolution = ZegoPrebuiltVideoResolution.hd720,
    this.layout = ZegoPrebuiltLayout.auto,
    this.showRoomTimer = false,
    this.showMyCameraToggleButton = true,
    this.showMyMicrophoneToggleButton = true,
    this.showAudioVideoSettingsButton = true,
    this.showTextChat = true,
    this.showUserList = true,
    this.showScreenSharingButton = true,
    this.showLeaveRoomConfirmDialog = true,
    this.brandingLogoUrl,
    this.language = ZegoPrebuiltLanguage.english,
    this.rawConfig,
  });

  final String roomId;
  final String userId;
  final String? userName;
  final ZegoPrebuiltScenario scenario;
  final int? maxUsers;
  final bool showPreJoinView;
  final String? preJoinViewTitle;
  final bool turnOnMicrophoneWhenJoining;
  final bool turnOnCameraWhenJoining;
  final bool useFrontFacingCamera;
  final ZegoPrebuiltVideoResolution videoResolution;
  final ZegoPrebuiltLayout layout;
  final bool showRoomTimer;
  final bool showMyCameraToggleButton;
  final bool showMyMicrophoneToggleButton;
  final bool showAudioVideoSettingsButton;
  final bool showTextChat;
  final bool showUserList;
  final bool showScreenSharingButton;
  final bool showLeaveRoomConfirmDialog;
  final String? brandingLogoUrl;
  final ZegoPrebuiltLanguage language;

  /// Raw key/value pairs forwarded verbatim to the JS-side
  /// ZegoCloudRoomConfig. Merged AFTER the typed fields, so any key here
  /// OVERRIDES the typed value.
  ///
  /// Values must be primitives, Lists, or Maps (no Functions — those throw
  /// ArgumentError with a pointer at the matching Stream getter).
  final Map<String, Object?>? rawConfig;
}
