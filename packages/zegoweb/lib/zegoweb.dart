/// zegoweb — unofficial Flutter web plugin for ZEGOCLOUD Express Video Web SDK.
///
/// Public API is re-exported from this barrel. Additional exports are added by
/// later tasks as each component lands.
library;

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

/// Plugin registrant required by Flutter's web plugin tooling. The actual
/// entry point is [ZegoWeb] (added in a later task); this class exists solely
/// so `flutter build web` can generate a registrant. It performs no work.
class ZegowebPluginRegistrant {
  static void registerWith(Registrar registrar) {
    // No-op. zegoweb exposes its API directly via static and instance
    // methods; there is no method channel to register.
  }
}
