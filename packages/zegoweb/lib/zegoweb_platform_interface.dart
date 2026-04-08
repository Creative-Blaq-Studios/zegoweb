import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'zegoweb_method_channel.dart';

abstract class ZegowebPlatform extends PlatformInterface {
  /// Constructs a ZegowebPlatform.
  ZegowebPlatform() : super(token: _token);

  static final Object _token = Object();

  static ZegowebPlatform _instance = MethodChannelZegoweb();

  /// The default instance of [ZegowebPlatform] to use.
  ///
  /// Defaults to [MethodChannelZegoweb].
  static ZegowebPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ZegowebPlatform] when
  /// they register themselves.
  static set instance(ZegowebPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
