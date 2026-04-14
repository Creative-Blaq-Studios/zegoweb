/// zegoweb — unofficial Flutter web plugin for ZEGOCLOUD Express Video Web SDK.
///
/// Public API is re-exported from this barrel. Additional exports are added by
/// Task 33 (final barrel).
library;

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

// Entry point
export 'src/zego_web.dart' show ZegoWeb;

// Logging
export 'src/log.dart' show ZegoLog;

// Engine + stream handles
export 'src/zego_engine.dart' show ZegoEngine;
export 'src/zego_local_stream.dart' show ZegoLocalStream;
export 'src/zego_remote_stream.dart' show ZegoRemoteStream;

// Flutter widget
export 'src/zego_video_view.dart' show ZegoVideoView;

// Configuration
export 'src/models/zego_config.dart' show ZegoEngineConfig, ZegoStreamConfig;

// Value types
export 'src/models/zego_user.dart' show ZegoUser;
export 'src/models/zego_device_info.dart' show ZegoDeviceInfo;
export 'src/models/zego_stream_info.dart' show ZegoStreamInfo;
export 'src/models/zego_events.dart'
    show ZegoRoomUserUpdate, ZegoRoomStreamUpdate, ZegoRemoteDeviceUpdate;
export 'src/models/zego_sound_level.dart'
    show ZegoSoundLevelInfo, ZegoSoundLevelUpdate;

// Enums
export 'src/models/zego_enums.dart'
    show
        ZegoLogLevel,
        ZegoScenario,
        ZegoUpdateType,
        ZegoRoomState,
        ZegoPermissionStatus,
        PermissionErrorKind;

// Errors
export 'src/models/zego_error.dart'
    show
        ZegoError,
        ZegoPermissionException,
        ZegoNetworkException,
        ZegoAuthException,
        ZegoDeviceException,
        ZegoStateError;

/// Plugin registrant required by Flutter's web plugin tooling. The actual
/// entry point is [ZegoWeb]; this class exists solely so `flutter build web`
/// can generate a registrant. It performs no work.
class ZegowebPluginRegistrant {
  static void registerWith(Registrar registrar) {
    // No-op. zegoweb exposes its API directly via static and instance
    // methods; there is no method channel to register.
  }
}
