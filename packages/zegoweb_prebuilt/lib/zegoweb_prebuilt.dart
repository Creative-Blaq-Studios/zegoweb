
import 'zegoweb_prebuilt_platform_interface.dart';

class ZegowebPrebuilt {
  Future<String?> getPlatformVersion() {
    return ZegowebPrebuiltPlatform.instance.getPlatformVersion();
  }
}
