// packages/zegoweb/test/zego_engine_token_refresh_test.dart
@TestOn('chrome')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb/src/models/zego_error.dart';
import 'package:zegoweb/src/models/zego_user.dart';
import 'package:zegoweb/src/zego_engine.dart';

import 'fixtures/fake_zego_js.dart';

void main() {
  group('ZegoEngine token refresh', () {
    test('tokenWillExpire → provider called → renewToken called', () async {
      final fake = FakeZegoJs();
      var providerCalls = 0;
      final tokens = <String>['tok-1', 'tok-2'];
      final engine = ZegoEngine.test(
        js: fake.asJs(),
        tokenProvider: () async {
          final t = tokens[providerCalls.clamp(0, tokens.length - 1)];
          providerCalls++;
          return t;
        },
      );
      addTearDown(engine.destroy);

      await engine.loginRoom(
        'r1',
        const ZegoUser(userId: 'u', userName: 'U'),
      );
      expect(providerCalls, 1);
      expect(fake.loginCalls.single.token, 'tok-1');

      fake.emitTokenWillExpire('r1', 30);
      await Future<void>.delayed(Duration.zero);
      // Give microtasks a couple more turns for provider → renewToken chain.
      await Future<void>.delayed(Duration.zero);

      expect(providerCalls, 2);
      expect(fake.renewTokenCalls, hasLength(1));
      expect(fake.renewTokenCalls.single.roomId, 'r1');
      expect(fake.renewTokenCalls.single.token, 'tok-2');
    });

    test('tokenProvider refresh failure emits ZegoAuthException on onError',
        () async {
      final fake = FakeZegoJs();
      var callCount = 0;
      final engine = ZegoEngine.test(
        js: fake.asJs(),
        tokenProvider: () async {
          callCount++;
          if (callCount == 1) return 'tok-1';
          throw StateError('refresh failed');
        },
      );
      addTearDown(engine.destroy);

      final errors = <ZegoError>[];
      final sub = engine.onError.listen(errors.add);
      await engine.loginRoom(
        'r1',
        const ZegoUser(userId: 'u', userName: 'U'),
      );
      fake.emitTokenWillExpire('r1', 30);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(errors, hasLength(1));
      expect(errors.single, isA<ZegoAuthException>());
      await sub.cancel();
    });
  });
}
