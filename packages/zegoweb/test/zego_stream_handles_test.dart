// packages/zegoweb/test/zego_stream_handles_test.dart
@TestOn('chrome')
library;

import 'dart:js_interop';

import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb/src/zego_local_stream.dart';
import 'package:zegoweb/src/zego_remote_stream.dart';

void main() {
  group('ZegoLocalStream', () {
    test('exposes the id it was constructed with', () {
      final js = JSObject();
      final stream = ZegoLocalStreamTestAccess.create('local-1', js);
      expect(stream.id, 'local-1');
    });

    test('two handles with the same id compare equal', () {
      final js = JSObject();
      final a = ZegoLocalStreamTestAccess.create('local-1', js);
      final b = ZegoLocalStreamTestAccess.create('local-1', js);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('two handles with different ids are not equal', () {
      final js = JSObject();
      final a = ZegoLocalStreamTestAccess.create('local-1', js);
      final b = ZegoLocalStreamTestAccess.create('local-2', js);
      expect(a, isNot(equals(b)));
    });

    test('toString includes id', () {
      final stream = ZegoLocalStreamTestAccess.create('s1', JSObject());
      expect(stream.toString(), contains('s1'));
    });
  });

  group('ZegoRemoteStream', () {
    test('exposes the id it was constructed with', () {
      final js = JSObject();
      final stream = ZegoRemoteStreamTestAccess.create('remote-1', js);
      expect(stream.id, 'remote-1');
    });

    test('equality is based on id', () {
      final js = JSObject();
      final a = ZegoRemoteStreamTestAccess.create('r-1', js);
      final b = ZegoRemoteStreamTestAccess.create('r-1', js);
      final c = ZegoRemoteStreamTestAccess.create('r-2', js);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('toString includes id', () {
      final stream = ZegoRemoteStreamTestAccess.create('rs1', JSObject());
      expect(stream.toString(), contains('rs1'));
    });
  });
}
