import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb/zegoweb.dart';
import 'package:zegoweb/zegoweb_platform_interface.dart';
import 'package:zegoweb/zegoweb_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockZegowebPlatform
    with MockPlatformInterfaceMixin
    implements ZegowebPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final ZegowebPlatform initialPlatform = ZegowebPlatform.instance;

  test('$MethodChannelZegoweb is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelZegoweb>());
  });

  test('getPlatformVersion', () async {
    Zegoweb zegowebPlugin = Zegoweb();
    MockZegowebPlatform fakePlatform = MockZegowebPlatform();
    ZegowebPlatform.instance = fakePlatform;

    expect(await zegowebPlugin.getPlatformVersion(), '42');
  });
}
