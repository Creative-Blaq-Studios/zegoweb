import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'zegoweb_platform_interface.dart';

/// An implementation of [ZegowebPlatform] that uses method channels.
class MethodChannelZegoweb extends ZegowebPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('zegoweb');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
