// packages/zegoweb/test/models/zego_stream_info_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb/src/models/zego_stream_info.dart';
import 'package:zegoweb/src/models/zego_user.dart';

void main() {
  const alice = ZegoUser(userId: 'u1', userName: 'Alice');
  const bob = ZegoUser(userId: 'u2', userName: 'Bob');

  group('ZegoStreamInfo', () {
    test('stores streamId, user, extraInfo', () {
      const s = ZegoStreamInfo(
        streamId: 'stream-1',
        user: alice,
        extraInfo: 'meta',
      );
      expect(s.streamId, 'stream-1');
      expect(s.user, alice);
      expect(s.extraInfo, 'meta');
    });

    test('extraInfo is optional and defaults to null', () {
      const s = ZegoStreamInfo(streamId: 'stream-1', user: alice);
      expect(s.extraInfo, isNull);
    });

    test('value equality: same fields are equal', () {
      const a = ZegoStreamInfo(
        streamId: 'stream-1',
        user: alice,
        extraInfo: 'meta',
      );
      const b = ZegoStreamInfo(
        streamId: 'stream-1',
        user: alice,
        extraInfo: 'meta',
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('value equality: different streamId is not equal', () {
      const a = ZegoStreamInfo(streamId: 'stream-1', user: alice);
      const b = ZegoStreamInfo(streamId: 'stream-2', user: alice);
      expect(a, isNot(equals(b)));
    });

    test('value equality: different user is not equal', () {
      const a = ZegoStreamInfo(streamId: 'stream-1', user: alice);
      const b = ZegoStreamInfo(streamId: 'stream-1', user: bob);
      expect(a, isNot(equals(b)));
    });

    test('value equality: different extraInfo is not equal', () {
      const a = ZegoStreamInfo(
        streamId: 'stream-1',
        user: alice,
        extraInfo: 'a',
      );
      const b = ZegoStreamInfo(
        streamId: 'stream-1',
        user: alice,
        extraInfo: 'b',
      );
      expect(a, isNot(equals(b)));
    });

    test('toString includes streamId and user', () {
      const s = ZegoStreamInfo(streamId: 'stream-1', user: alice);
      expect(s.toString(), contains('stream-1'));
      expect(s.toString(), contains('u1'));
    });
  });
}
