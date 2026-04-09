// packages/zegoweb/test/interop/promise_adapter_test.dart
@TestOn('chrome')
library;

import 'dart:js_interop';

import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb/src/interop/promise_adapter.dart';
import 'package:zegoweb/src/models/zego_error.dart';

JSPromise<JSAny?> _resolved(JSAny? value) {
  return JSPromise<JSAny?>(((JSFunction resolve, JSFunction reject) {
    resolve.callAsFunction(null, value);
  }).toJS);
}

JSPromise<JSAny?> _rejected(JSAny? error) {
  return JSPromise<JSAny?>(((JSFunction resolve, JSFunction reject) {
    reject.callAsFunction(null, error);
  }).toJS);
}

void main() {
  group('futureFromJsPromise', () {
    test('resolves with the JS value unchanged when no converter', () async {
      final result = await futureFromJsPromise<JSAny?>(_resolved('ok'.toJS));
      expect((result as JSString).toDart, 'ok');
    });

    test('applies convert on resolved value', () async {
      final result = await futureFromJsPromise<int>(
        _resolved(42.toJS),
        convert: (raw) => (raw as JSNumber).toDartInt,
      );
      expect(result, 42);
    });

    test('rejected with {code, message} maps to ZegoError', () async {
      final err =
          <String, Object?>{'code': 1002001, 'message': 'token bad'}.jsify();
      await expectLater(
        futureFromJsPromise<JSAny?>(_rejected(err)),
        throwsA(
          isA<ZegoError>()
              .having((e) => e.code, 'code', 1002001)
              .having((e) => e.message, 'message', 'token bad'),
        ),
      );
    });

    test('rejected with arbitrary string wraps as ZegoError(-1, ...)',
        () async {
      await expectLater(
        futureFromJsPromise<JSAny?>(_rejected('boom'.toJS)),
        throwsA(
          isA<ZegoError>()
              .having((e) => e.code, 'code', -1)
              .having((e) => e.message, 'message', contains('boom')),
        ),
      );
    });

    test('rejected with null wraps as ZegoError(-1, "unknown")', () async {
      await expectLater(
        futureFromJsPromise<JSAny?>(_rejected(null)),
        throwsA(isA<ZegoError>().having((e) => e.code, 'code', -1)),
      );
    });
  });
}
