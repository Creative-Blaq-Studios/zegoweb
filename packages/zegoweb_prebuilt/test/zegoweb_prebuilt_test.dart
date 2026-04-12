import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb_prebuilt/zegoweb_prebuilt.dart';
import 'package:zegoweb_prebuilt/zegoweb_prebuilt_platform_interface.dart';
import 'package:zegoweb_prebuilt/zegoweb_prebuilt_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockZegowebPrebuiltPlatform
    with MockPlatformInterfaceMixin
    implements ZegowebPrebuiltPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final ZegowebPrebuiltPlatform initialPlatform = ZegowebPrebuiltPlatform.instance;

  test('$MethodChannelZegowebPrebuilt is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelZegowebPrebuilt>());
  });

  test('getPlatformVersion', () async {
    ZegowebPrebuilt zegowebPrebuiltPlugin = ZegowebPrebuilt();
    MockZegowebPrebuiltPlatform fakePlatform = MockZegowebPrebuiltPlatform();
    ZegowebPrebuiltPlatform.instance = fakePlatform;

    expect(await zegowebPrebuiltPlugin.getPlatformVersion(), '42');
  });
}
