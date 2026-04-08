
import 'zegoweb_platform_interface.dart';

class Zegoweb {
  Future<String?> getPlatformVersion() {
    return ZegowebPlatform.instance.getPlatformVersion();
  }
}
