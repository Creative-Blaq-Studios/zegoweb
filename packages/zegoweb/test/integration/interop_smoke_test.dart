// packages/zegoweb/test/integration/interop_smoke_test.dart
//
// Interop-layer smoke test. Exercises SdkLoader + EventBridge + promise
// adapter against the FakeZegoJs fixture in a single end-to-end scenario,
// WITHOUT loading the real ZEGO SDK.
//
// The real-SDK integration test lives in example/integration_test/ and is
// gated by credentials.
@TestOn('chrome')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter_test/flutter_test.dart';
import 'package:web/web.dart' as web;
import 'package:zegoweb/src/interop/event_bridge.dart';
import 'package:zegoweb/src/interop/promise_adapter.dart';
import 'package:zegoweb/src/interop/zego_js.dart';
import 'package:zegoweb/src/models/zego_error.dart';
import 'package:zegoweb/src/sdk_loader.dart';

import '../fixtures/fake_zego_js.dart';

void main() {
  test('interop layers compose end-to-end against FakeZegoJs', () async {
    // 1. Install the fake as window.ZegoExpressEngine and reset loader state.
    SdkLoader.debugReset();
    final fake = FakeZegoJs()..installAsWindowGlobal();
    addTearDown(() {
      fake.uninstall();
      SdkLoader.debugReset();
    });

    // 2. SdkLoader.ready resolves immediately because the global is present.
    await SdkLoader.ready.timeout(const Duration(seconds: 1));
    expect(isZegoJsLoaded, isTrue);

    // 3. Construct a JS engine via the fake — we bypass `new` since the
    //    fake's installed global is a plain JSFunction, not a class.
    final engine = fake.asJs();

    // 4. EventBridge delivers fake-driven events as Dart stream events.
    final bridge = EventBridge(engine);
    final stream = bridge.registerEvent<String>(
      'roomStateUpdate',
      (raw) => ((raw as JSObject)['state'] as JSString).toDart,
    );
    final received = <String>[];
    final sub = stream.listen(received.add);

    fake.driveEvent(
      'roomStateUpdate',
      <String, Object?>{'state': 'CONNECTED'}.jsify(),
    );
    await Future<void>.delayed(Duration.zero);
    expect(received, <String>['CONNECTED']);

    // 5. Promise adapter maps a fake-rejected promise into a ZegoError.
    fake.enqueueRejectedWithCode('loginRoom', 1002033, 'token expired');
    final loginRoom = engine['loginRoom'] as JSFunction;
    final jsPromise = loginRoom.callAsFunction(
      engine,
      'room-1'.toJS,
      'bad-token'.toJS,
      <String, Object?>{'userID': 'u1', 'userName': 'U1'}.jsify(),
    ) as JSPromise<JSAny?>;

    await expectLater(
      futureFromJsPromise<JSAny?>(jsPromise),
      throwsA(
        isA<ZegoError>()
            .having((e) => e.code, 'code', 1002033)
            .having((e) => e.message, 'message', 'token expired'),
      ),
    );

    // 6. Teardown: bridge.dispose removes the JS listener.
    expect(fake.listenerCount('roomStateUpdate'), 1);
    await sub.cancel();
    await bridge.dispose();
    expect(fake.listenerCount('roomStateUpdate'), 0);

    // Reference web.window to keep the import live even if unused above.
    expect(web.window, isNotNull);
  });
}
