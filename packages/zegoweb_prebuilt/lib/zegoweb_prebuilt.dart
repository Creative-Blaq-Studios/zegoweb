/// zegoweb_prebuilt — unofficial community Flutter web plugin wrapping
/// ZEGOCLOUD's @zegocloud/zego-uikit-prebuilt UIKit.
///
/// Not affiliated with or endorsed by ZEGOCLOUD.
library;

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

// Entry point + instance
export 'src/zego_prebuilt.dart' show ZegoPrebuilt;

// Flutter widget
export 'src/zego_prebuilt_view.dart' show ZegoPrebuiltView;

// Configuration + enums
export 'src/zego_prebuilt_config.dart'
    show
        ZegoPrebuiltConfig,
        ZegoPrebuiltScenario,
        ZegoPrebuiltLayout,
        ZegoPrebuiltVideoResolution,
        ZegoPrebuiltLanguage;

// Value types
export 'src/zego_prebuilt_user.dart' show ZegoPrebuiltUser;

// Errors
export 'src/zego_prebuilt_error.dart' show ZegoError, ZegoStateError;

/// Plugin registrant required by Flutter's web plugin tooling.
class ZegowebPrebuiltPluginRegistrant {
  static void registerWith(Registrar registrar) {
    // No-op. zegoweb_prebuilt exposes its API directly via static and
    // instance methods; there is no method channel to register.
  }
}
