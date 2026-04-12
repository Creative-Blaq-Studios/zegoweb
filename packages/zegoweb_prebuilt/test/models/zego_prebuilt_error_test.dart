import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb_prebuilt/src/zego_prebuilt_error.dart';

void main() {
  group('ZegoError', () {
    test('stores code and message', () {
      const e = ZegoError(-1, 'something went wrong');
      expect(e.code, -1);
      expect(e.message, 'something went wrong');
    });

    test('toString includes code and message', () {
      const e = ZegoError(42, 'test error');
      expect(e.toString(), contains('42'));
      expect(e.toString(), contains('test error'));
    });

    test('cause is preserved', () {
      final cause = Exception('root cause');
      final e = ZegoError(-1, 'wrapped', cause: cause);
      expect(e.cause, same(cause));
    });

    test('implements Exception', () {
      const e = ZegoError(0, 'test');
      expect(e, isA<Exception>());
    });
  });

  group('ZegoStateError', () {
    test('stores code and message', () {
      const e = ZegoStateError(-1, 'bad state');
      expect(e.code, -1);
      expect(e.message, 'bad state');
    });

    test('toString includes code and message', () {
      const e = ZegoStateError(1, 'state error');
      expect(e.toString(), contains('1'));
      expect(e.toString(), contains('state error'));
    });

    test('extends ZegoError', () {
      const e = ZegoStateError(0, 'test');
      expect(e, isA<ZegoError>());
    });
  });
}
