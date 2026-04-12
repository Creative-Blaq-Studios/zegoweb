import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'zegoweb_prebuilt_method_channel.dart';

abstract class ZegowebPrebuiltPlatform extends PlatformInterface {
  /// Constructs a ZegowebPrebuiltPlatform.
  ZegowebPrebuiltPlatform() : super(token: _token);

  static final Object _token = Object();

  static ZegowebPrebuiltPlatform _instance = MethodChannelZegowebPrebuilt();

  /// The default instance of [ZegowebPrebuiltPlatform] to use.
  ///
  /// Defaults to [MethodChannelZegowebPrebuilt].
  static ZegowebPrebuiltPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ZegowebPrebuiltPlatform] when
  /// they register themselves.
  static set instance(ZegowebPrebuiltPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
