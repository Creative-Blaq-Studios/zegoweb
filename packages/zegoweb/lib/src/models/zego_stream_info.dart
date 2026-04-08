// packages/zegoweb/lib/src/models/zego_stream_info.dart
import 'package:meta/meta.dart';

import 'zego_user.dart';

/// Metadata for a stream as reported by `roomStreamUpdate` events.
@immutable
class ZegoStreamInfo {
  const ZegoStreamInfo({
    required this.streamId,
    required this.user,
    this.extraInfo,
  });

  final String streamId;
  final ZegoUser user;
  final String? extraInfo;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ZegoStreamInfo &&
        other.streamId == streamId &&
        other.user == user &&
        other.extraInfo == extraInfo;
  }

  @override
  int get hashCode => Object.hash(streamId, user, extraInfo);

  @override
  String toString() =>
      'ZegoStreamInfo(streamId: $streamId, user: $user, extraInfo: $extraInfo)';
}
