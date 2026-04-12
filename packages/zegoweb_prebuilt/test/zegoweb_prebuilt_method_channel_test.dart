import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb_prebuilt/zegoweb_prebuilt_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelZegowebPrebuilt platform = MethodChannelZegowebPrebuilt();
  const MethodChannel channel = MethodChannel('zegoweb_prebuilt');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          return '42';
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
