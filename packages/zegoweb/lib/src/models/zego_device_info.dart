// packages/zegoweb/lib/src/models/zego_device_info.dart
import 'package:meta/meta.dart';

/// A media input device (camera or microphone) as reported by the JS SDK.
@immutable
class ZegoDeviceInfo {
  const ZegoDeviceInfo({required this.deviceId, required this.deviceName});

  final String deviceId;
  final String deviceName;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ZegoDeviceInfo &&
        other.deviceId == deviceId &&
        other.deviceName == deviceName;
  }

  @override
  int get hashCode => Object.hash(deviceId, deviceName);

  @override
  String toString() =>
      'ZegoDeviceInfo(deviceId: $deviceId, deviceName: $deviceName)';
}
