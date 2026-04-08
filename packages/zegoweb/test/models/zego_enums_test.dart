// packages/zegoweb/test/models/zego_enums_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb/src/models/zego_enums.dart';

void main() {
  group('ZegoLogLevel', () {
    test('has all five levels in order', () {
      expect(ZegoLogLevel.values, [
        ZegoLogLevel.verbose,
        ZegoLogLevel.info,
        ZegoLogLevel.warn,
        ZegoLogLevel.error,
        ZegoLogLevel.off,
      ]);
    });
  });

  group('ZegoScenario', () {
    test('has general, communication, live', () {
      expect(ZegoScenario.values, [
        ZegoScenario.general,
        ZegoScenario.communication,
        ZegoScenario.live,
      ]);
    });
  });

  group('ZegoUpdateType', () {
    test('has add and delete', () {
      expect(ZegoUpdateType.values, [
        ZegoUpdateType.add,
        ZegoUpdateType.delete,
      ]);
    });
  });

  group('ZegoRoomState', () {
    test('has disconnected, connecting, connected', () {
      expect(ZegoRoomState.values, [
        ZegoRoomState.disconnected,
        ZegoRoomState.connecting,
        ZegoRoomState.connected,
      ]);
    });
  });

  group('ZegoPermissionStatus', () {
    test('has granted, denied, prompt, unavailable', () {
      expect(ZegoPermissionStatus.values, [
        ZegoPermissionStatus.granted,
        ZegoPermissionStatus.denied,
        ZegoPermissionStatus.prompt,
        ZegoPermissionStatus.unavailable,
      ]);
    });
  });

  group('PermissionErrorKind', () {
    test('has denied, notFound, inUse, insecureContext', () {
      expect(PermissionErrorKind.values, [
        PermissionErrorKind.denied,
        PermissionErrorKind.notFound,
        PermissionErrorKind.inUse,
        PermissionErrorKind.insecureContext,
      ]);
    });
  });
}
