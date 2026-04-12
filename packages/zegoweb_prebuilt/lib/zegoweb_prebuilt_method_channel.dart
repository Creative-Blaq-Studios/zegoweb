import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'zegoweb_prebuilt_platform_interface.dart';

/// An implementation of [ZegowebPrebuiltPlatform] that uses method channels.
class MethodChannelZegowebPrebuilt extends ZegowebPrebuiltPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('zegoweb_prebuilt');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
