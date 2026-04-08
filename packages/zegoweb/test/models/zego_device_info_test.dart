// packages/zegoweb/test/models/zego_device_info_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb/src/models/zego_device_info.dart';

void main() {
  group('ZegoDeviceInfo', () {
    test('stores deviceId and deviceName', () {
      const d = ZegoDeviceInfo(deviceId: 'cam-1', deviceName: 'FaceTime HD');
      expect(d.deviceId, 'cam-1');
      expect(d.deviceName, 'FaceTime HD');
    });

    test('value equality: same fields are equal', () {
      const a = ZegoDeviceInfo(deviceId: 'cam-1', deviceName: 'FaceTime HD');
      const b = ZegoDeviceInfo(deviceId: 'cam-1', deviceName: 'FaceTime HD');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('value equality: different deviceId is not equal', () {
      const a = ZegoDeviceInfo(deviceId: 'cam-1', deviceName: 'FaceTime HD');
      const b = ZegoDeviceInfo(deviceId: 'cam-2', deviceName: 'FaceTime HD');
      expect(a, isNot(equals(b)));
    });

    test('toString includes both fields', () {
      const d = ZegoDeviceInfo(deviceId: 'cam-1', deviceName: 'FaceTime HD');
      expect(d.toString(), contains('cam-1'));
      expect(d.toString(), contains('FaceTime HD'));
    });
  });
}
