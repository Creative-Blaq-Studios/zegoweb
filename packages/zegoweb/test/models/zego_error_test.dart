// packages/zegoweb/test/models/zego_error_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb/src/models/zego_enums.dart';
import 'package:zegoweb/src/models/zego_error.dart';

void main() {
  group('ZegoError', () {
    test('stores code, message, cause', () {
      const err = ZegoError(42, 'boom', cause: 'underlying');
      expect(err.code, 42);
      expect(err.message, 'boom');
      expect(err.cause, 'underlying');
      expect(err.stackTrace, isNull);
    });

    test('cause and stackTrace are optional', () {
      const err = ZegoError(1, 'x');
      expect(err.cause, isNull);
      expect(err.stackTrace, isNull);
    });

    test('stores stackTrace when provided', () {
      final st = StackTrace.current;
      final err = ZegoError(1, 'x', cause: 'c', stackTrace: st);
      expect(err.stackTrace, same(st));
    });

    test('implements Exception', () {
      const err = ZegoError(1, 'x');
      expect(err, isA<Exception>());
    });

    test('toString includes type, code, and message', () {
      const err = ZegoError(42, 'boom');
      expect(err.toString(), contains('ZegoError'));
      expect(err.toString(), contains('42'));
      expect(err.toString(), contains('boom'));
    });

    test('toString includes cause when present', () {
      const err = ZegoError(42, 'boom', cause: 'underlying');
      expect(err.toString(), contains('underlying'));
    });
  });

  group('ZegoPermissionException', () {
    test('stores kind in addition to base fields', () {
      const err = ZegoPermissionException(
        1001,
        'denied by user',
        kind: PermissionErrorKind.denied,
      );
      expect(err.code, 1001);
      expect(err.message, 'denied by user');
      expect(err.kind, PermissionErrorKind.denied);
    });

    test('is a ZegoError', () {
      const err = ZegoPermissionException(
        1001,
        'x',
        kind: PermissionErrorKind.denied,
      );
      expect(err, isA<ZegoError>());
    });

    test('toString includes the kind', () {
      const err = ZegoPermissionException(
        1001,
        'x',
        kind: PermissionErrorKind.notFound,
      );
      expect(err.toString(), contains('notFound'));
    });
  });

  group('ZegoNetworkException', () {
    test('is a ZegoError with code and message', () {
      const err = ZegoNetworkException(2001, 'disconnected');
      expect(err, isA<ZegoError>());
      expect(err.code, 2001);
      expect(err.message, 'disconnected');
    });

    test('toString uses its own type name', () {
      const err = ZegoNetworkException(2001, 'disconnected');
      expect(err.toString(), contains('ZegoNetworkException'));
    });
  });

  group('ZegoAuthException', () {
    test('is a ZegoError with code and message', () {
      const err = ZegoAuthException(3001, 'token expired');
      expect(err, isA<ZegoError>());
      expect(err.toString(), contains('ZegoAuthException'));
    });
  });

  group('ZegoDeviceException', () {
    test('is a ZegoError with code and message', () {
      const err = ZegoDeviceException(4001, 'no camera');
      expect(err, isA<ZegoError>());
      expect(err.toString(), contains('ZegoDeviceException'));
    });
  });

  group('ZegoStateError', () {
    test('is a ZegoError with code and message', () {
      const err = ZegoStateError(5001, 'engine disposed');
      expect(err, isA<ZegoError>());
      expect(err.toString(), contains('ZegoStateError'));
      expect(err.toString(), contains('engine disposed'));
    });
  });
}
