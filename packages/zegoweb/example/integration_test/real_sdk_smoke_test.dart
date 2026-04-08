// packages/zegoweb/example/integration_test/real_sdk_smoke_test.dart
//
// One smoke test against the real ZEGO Express Web SDK. Gated by
// --dart-define=ZEGO_APP_ID=... so default CI does not need credentials.
//
// Run:
//   cd packages/zegoweb/example
//   flutter test integration_test/real_sdk_smoke_test.dart -d chrome \
//     --dart-define=ZEGO_APP_ID=123456789 \
//     --dart-define=ZEGO_SERVER=wss://webliveroom-api.zego.im/ws \
//     --dart-define=ZEGO_TOKEN=<token> \
//     --dart-define=ZEGO_ROOM=smoke-room \
//     --dart-define=ZEGO_USER_ID=smoke-bot

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:zegoweb/zegoweb.dart';

const _appIdStr = String.fromEnvironment('ZEGO_APP_ID');
const _server = String.fromEnvironment(
  'ZEGO_SERVER',
  defaultValue: 'wss://webliveroom-api.zego.im/ws',
);
const _token = String.fromEnvironment('ZEGO_TOKEN', defaultValue: '');
const _roomId = String.fromEnvironment(
  'ZEGO_ROOM',
  defaultValue: 'zegoweb-smoke',
);
const _userId = String.fromEnvironment(
  'ZEGO_USER_ID',
  defaultValue: 'smoke-bot',
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'real SDK smoke — load, login, publish, tear down',
    (tester) async {
      if (_appIdStr.isEmpty) {
        // Skipped: credentials not provided.
        // ignore: avoid_print
        print('ZEGO_APP_ID not set — skipping real SDK smoke test.');
        return;
      }

      ZegoWeb.setLogLevel(ZegoLogLevel.info);
      await ZegoWeb.loadScript();

      final engine = await ZegoWeb.createEngine(
        ZegoEngineConfig(
          appId: int.parse(_appIdStr),
          server: _server,
          scenario: ZegoScenario.communication,
          tokenProvider: () async => _token,
        ),
      );

      final errors = <ZegoError>[];
      final roomStates = <ZegoRoomState>[];
      final errSub = engine.onError.listen(errors.add);
      final roomSub = engine.onRoomStateChanged.listen(roomStates.add);

      try {
        await engine.loginRoom(
          _roomId,
          const ZegoUser(userId: _userId, userName: 'Smoke Bot'),
        );

        final local = await engine.createLocalStream(
          config: const ZegoStreamConfig(camera: true, microphone: true),
        );

        final streamId =
            'smoke-$_userId-${DateTime.now().millisecondsSinceEpoch}';
        await engine.startPublishing(streamId, local);

        // Pump events for ~3 seconds.
        await tester.pump(const Duration(seconds: 3));
        await Future<void>.delayed(const Duration(seconds: 3));

        expect(errors, isEmpty, reason: 'no errors expected during smoke run');
        expect(
          roomStates,
          isNotEmpty,
          reason: 'expected at least one room state event',
        );
      } finally {
        await errSub.cancel();
        await roomSub.cancel();
        await engine.destroy();
      }
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );
}
