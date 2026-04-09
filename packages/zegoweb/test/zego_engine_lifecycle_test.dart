// packages/zegoweb/test/zego_engine_lifecycle_test.dart
@TestOn('chrome')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb/src/models/zego_error.dart';
import 'package:zegoweb/src/models/zego_user.dart';
import 'package:zegoweb/src/zego_engine.dart';

import 'fixtures/fake_zego_js.dart';

void main() {
  group('ZegoEngine skeleton', () {
    test('constructs with a fake JS handle', () {
      final fake = FakeZegoJs();
      final engine = ZegoEngine.test(
        js: fake.asJs(),
        tokenProvider: () async => 'tok',
      );
      expect(engine, isNotNull);
      engine.destroy();
    });

    test('destroy closes all controllers and is safe to double-call', () async {
      final fake = FakeZegoJs();
      final engine = ZegoEngine.test(
        js: fake.asJs(),
        tokenProvider: () async => 'tok',
      );
      await engine.destroy();
      await engine.destroy();
    });

    test('room method after destroy throws ZegoStateError', () async {
      final fake = FakeZegoJs();
      final engine = ZegoEngine.test(
        js: fake.asJs(),
        tokenProvider: () async => 'tok',
      );
      await engine.destroy();
      await expectLater(
        engine.loginRoom('r1', const ZegoUser(userId: 'u', userName: 'U')),
        throwsA(isA<ZegoStateError>()),
      );
    });

    test('createLocalStream after destroy throws ZegoStateError', () async {
      final fake = FakeZegoJs();
      final engine = ZegoEngine.test(
        js: fake.asJs(),
        tokenProvider: () async => 'tok',
      );
      await engine.destroy();
      await expectLater(
        engine.createLocalStream(),
        throwsA(isA<ZegoStateError>()),
      );
    });
  });
}
