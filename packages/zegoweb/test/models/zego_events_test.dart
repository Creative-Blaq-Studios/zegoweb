// packages/zegoweb/test/models/zego_events_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb/src/models/zego_enums.dart';
import 'package:zegoweb/src/models/zego_events.dart';
import 'package:zegoweb/src/models/zego_stream_info.dart';
import 'package:zegoweb/src/models/zego_user.dart';

void main() {
  const alice = ZegoUser(userId: 'u1', userName: 'Alice');
  const bob = ZegoUser(userId: 'u2', userName: 'Bob');

  group('ZegoRoomUserUpdate', () {
    test('stores roomId, type, users', () {
      const evt = ZegoRoomUserUpdate(
        roomId: 'room-1',
        type: ZegoUpdateType.add,
        users: [alice, bob],
      );
      expect(evt.roomId, 'room-1');
      expect(evt.type, ZegoUpdateType.add);
      expect(evt.users, [alice, bob]);
    });

    test('value equality: same fields are equal', () {
      const a = ZegoRoomUserUpdate(
        roomId: 'room-1',
        type: ZegoUpdateType.add,
        users: [alice],
      );
      const b = ZegoRoomUserUpdate(
        roomId: 'room-1',
        type: ZegoUpdateType.add,
        users: [alice],
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('value equality: different type is not equal', () {
      const a = ZegoRoomUserUpdate(
        roomId: 'room-1',
        type: ZegoUpdateType.add,
        users: [alice],
      );
      const b = ZegoRoomUserUpdate(
        roomId: 'room-1',
        type: ZegoUpdateType.delete,
        users: [alice],
      );
      expect(a, isNot(equals(b)));
    });

    test('toString includes roomId and type', () {
      const evt = ZegoRoomUserUpdate(
        roomId: 'room-1',
        type: ZegoUpdateType.add,
        users: [alice],
      );
      expect(evt.toString(), contains('room-1'));
      expect(evt.toString(), contains('add'));
    });
  });

  group('ZegoRoomStreamUpdate', () {
    const streamInfo = ZegoStreamInfo(streamId: 'stream-1', user: alice);

    test('stores roomId, type, streams', () {
      const evt = ZegoRoomStreamUpdate(
        roomId: 'room-1',
        type: ZegoUpdateType.add,
        streams: [streamInfo],
      );
      expect(evt.roomId, 'room-1');
      expect(evt.type, ZegoUpdateType.add);
      expect(evt.streams, [streamInfo]);
    });

    test('value equality: same fields are equal', () {
      const a = ZegoRoomStreamUpdate(
        roomId: 'room-1',
        type: ZegoUpdateType.delete,
        streams: [streamInfo],
      );
      const b = ZegoRoomStreamUpdate(
        roomId: 'room-1',
        type: ZegoUpdateType.delete,
        streams: [streamInfo],
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString includes roomId and type', () {
      const evt = ZegoRoomStreamUpdate(
        roomId: 'room-1',
        type: ZegoUpdateType.delete,
        streams: [streamInfo],
      );
      expect(evt.toString(), contains('room-1'));
      expect(evt.toString(), contains('delete'));
    });
  });

  group('ZegoRoomStateChanged', () {
    test('stores roomId, state, errorCode, extendedData', () {
      const evt = ZegoRoomStateChanged(
        roomId: 'room-1',
        state: ZegoRoomState.connected,
        errorCode: 0,
      );
      expect(evt.roomId, 'room-1');
      expect(evt.state, ZegoRoomState.connected);
      expect(evt.errorCode, 0);
      expect(evt.extendedData, isNull);
    });
  });

  group('ZegoPublisherStateChanged', () {
    test('isFailed is true when state is PUBLISH_FAILED', () {
      const evt = ZegoPublisherStateChanged(
        streamId: 's1',
        state: 'PUBLISH_FAILED',
        errorCode: 1003024,
      );
      expect(evt.isFailed, isTrue);
    });

    test('isFailed is false when state is PUBLISHING', () {
      const evt = ZegoPublisherStateChanged(
        streamId: 's1',
        state: 'PUBLISHING',
        errorCode: 0,
      );
      expect(evt.isFailed, isFalse);
    });
  });

  group('ZegoPlayerStateChanged', () {
    test('isFailed is true when state is PLAY_FAILED', () {
      const evt = ZegoPlayerStateChanged(
        streamId: 's1',
        state: 'PLAY_FAILED',
        errorCode: 1004024,
      );
      expect(evt.isFailed, isTrue);
    });
  });

  group('ZegoTokenWillExpire', () {
    test('stores roomId and remainingSeconds', () {
      const evt = ZegoTokenWillExpire(roomId: 'r1', remainingSeconds: 30);
      expect(evt.roomId, 'r1');
      expect(evt.remainingSeconds, 30);
    });
  });
}
