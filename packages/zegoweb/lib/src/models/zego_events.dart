// packages/zegoweb/lib/src/models/zego_events.dart
import 'package:meta/meta.dart';

import 'zego_enums.dart';
import 'zego_stream_info.dart';
import 'zego_user.dart';

/// Payload for `ZegoEngine.onRoomUserUpdate`. Mirrors the JS SDK's
/// `roomUserUpdate` event: a delta of users added to or removed from the
/// current room.
@immutable
class ZegoRoomUserUpdate {
  const ZegoRoomUserUpdate({
    required this.roomId,
    required this.type,
    required this.users,
  });

  final String roomId;
  final ZegoUpdateType type;
  final List<ZegoUser> users;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ZegoRoomUserUpdate) return false;
    if (other.roomId != roomId) return false;
    if (other.type != type) return false;
    if (other.users.length != users.length) return false;
    for (var i = 0; i < users.length; i++) {
      if (other.users[i] != users[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(roomId, type, Object.hashAll(users));

  @override
  String toString() =>
      'ZegoRoomUserUpdate(roomId: $roomId, type: ${type.name}, users: $users)';
}

/// Payload for `ZegoEngine.onRoomStreamUpdate`. Mirrors the JS SDK's
/// `roomStreamUpdate` event.
@immutable
class ZegoRoomStreamUpdate {
  const ZegoRoomStreamUpdate({
    required this.roomId,
    required this.type,
    required this.streams,
  });

  final String roomId;
  final ZegoUpdateType type;
  final List<ZegoStreamInfo> streams;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ZegoRoomStreamUpdate) return false;
    if (other.roomId != roomId) return false;
    if (other.type != type) return false;
    if (other.streams.length != streams.length) return false;
    for (var i = 0; i < streams.length; i++) {
      if (other.streams[i] != streams[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(roomId, type, Object.hashAll(streams));

  @override
  String toString() =>
      'ZegoRoomStreamUpdate(roomId: $roomId, type: ${type.name}, streams: $streams)';
}

/// Payload for `ZegoEngine.onRoomStateChanged` and the internal
/// `EventBridge.onRoomStateUpdate` typed stream. Mirrors the JS SDK's
/// `roomStateUpdate` event.
@immutable
class ZegoRoomStateChanged {
  const ZegoRoomStateChanged({
    required this.roomId,
    required this.state,
    this.errorCode,
    this.extendedData,
  });

  final String roomId;
  final ZegoRoomState state;
  final int? errorCode;
  final String? extendedData;

  @override
  String toString() =>
      'ZegoRoomStateChanged(roomId: $roomId, state: ${state.name}, '
      'errorCode: $errorCode, extendedData: $extendedData)';
}

/// Payload for the JS SDK's `publisherStateUpdate` event.
@immutable
class ZegoPublisherStateChanged {
  const ZegoPublisherStateChanged({
    required this.streamId,
    required this.state,
    this.errorCode,
    this.extendedData,
  });

  final String streamId;
  final String state;
  final int? errorCode;
  final String? extendedData;

  /// True when [state] indicates a terminal publish failure.
  bool get isFailed => state == 'PUBLISH_FAILED' || state == 'NO_PUBLISH';

  @override
  String toString() =>
      'ZegoPublisherStateChanged(streamId: $streamId, state: $state, '
      'errorCode: $errorCode)';
}

/// Payload for the JS SDK's `playerStateUpdate` event.
@immutable
class ZegoPlayerStateChanged {
  const ZegoPlayerStateChanged({
    required this.streamId,
    required this.state,
    this.errorCode,
    this.extendedData,
  });

  final String streamId;
  final String state;
  final int? errorCode;
  final String? extendedData;

  /// True when [state] indicates a terminal play failure.
  bool get isFailed => state == 'PLAY_FAILED' || state == 'NO_PLAY';

  @override
  String toString() =>
      'ZegoPlayerStateChanged(streamId: $streamId, state: $state, '
      'errorCode: $errorCode)';
}

/// Payload for the JS SDK's `tokenWillExpire` event.
@immutable
class ZegoTokenWillExpire {
  const ZegoTokenWillExpire({
    required this.roomId,
    required this.remainingSeconds,
  });

  final String roomId;
  final int remainingSeconds;

  @override
  String toString() =>
      'ZegoTokenWillExpire(roomId: $roomId, remainingSeconds: $remainingSeconds)';
}

/// Payload for the JS SDK's `remoteCameraStatusUpdate` and
/// `remoteMicStatusUpdate` events.
///
/// [status] mirrors the JS `ZegoRemoteDeviceStatus` enum: `"OPEN"` means the
/// device is active; any other value (`"MUTE"`, `"DISABLE"`, `"INTERRUPT"`,
/// etc.) means the device is unavailable.
@immutable
class ZegoRemoteDeviceUpdate {
  const ZegoRemoteDeviceUpdate({
    required this.streamId,
    required this.status,
  });

  final String streamId;

  /// Raw JS status string. Use [isActive] for a boolean interpretation.
  final String status;

  /// `true` when the device is open (status == `"OPEN"`).
  bool get isActive => status == 'OPEN';

  @override
  String toString() =>
      'ZegoRemoteDeviceUpdate(streamId: $streamId, status: $status)';
}
